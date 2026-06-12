param([ValidateSet('STATUS','SELECT','PREPARE')][string]$Mode='STATUS',[ValidateSet('APPROVE','REJECT','REQUEST_CHANGES')][string]$Decision='APPROVE',[switch]$RealWrite)
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.UTF8Encoding]::new()
$ModuleRoot=Split-Path -Parent $PSScriptRoot
$Reports=Join-Path $ModuleRoot 'reports'
$SnapshotPath=Join-Path $Reports 'sheets-operational-control-panel-readonly-snapshot.v1.json'
$MetricsPath=Join-Path $Reports 'sheets-operational-control-panel-metrics.v1.json'
$EngineContractPath=Join-Path $Reports 'sheets-reusable-governed-human-operation-loop-contract.v1.json'
$BindingPath=Join-Path $Reports 'sheets-operational-control-panel-engine-binding.v1.json'
foreach($Path in @($SnapshotPath,$MetricsPath,$EngineContractPath)){if(-not(Test-Path $Path)){throw ('REQUIRED_EVIDENCE_MISSING_'+[IO.Path]::GetFileName($Path))}}
$Snapshot=Get-Content $SnapshotPath -Raw|ConvertFrom-Json
$Metrics=Get-Content $MetricsPath -Raw|ConvertFrom-Json
$Engine=Get-Content $EngineContractPath -Raw|ConvertFrom-Json
if(-not $Snapshot.ok -or -not $Metrics.ok -or -not $Engine.ok){throw 'LAUNCHER_EVIDENCE_INVALID'}
if($RealWrite){if(-not(Test-Path $BindingPath)){throw 'REAL_WRITE_BLOCKED_ENGINE_BINDING_NOT_READY'};$Binding=Get-Content $BindingPath -Raw|ConvertFrom-Json;if(-not $Binding.ok -or -not $Binding.real_execution_binding_ready){throw 'REAL_WRITE_BLOCKED_ENGINE_BINDING_INVALID'};throw 'REAL_WRITE_BLOCKED_USE_GOVERNED_ENGINE_ENTRYPOINT'}
function Find-HeaderIndex([object[]]$Headers,[string[]]$Candidates){for($i=0;$i-lt$Headers.Count;$i++){$Name=([string]$Headers[$i]).Trim().ToLowerInvariant();if($Candidates-contains$Name){return $i}};return -1}
function Read-Value([object[]]$Values,[int]$Index){if($Index-lt 0 -or $Index-ge$Values.Count){return ''};return ([string]$Values[$Index]).Trim()}
[object[]]$Headers=@($Snapshot.queue.headers)
$IdIndex=Find-HeaderIndex $Headers @('queue_id','id','task_id','operation_id')
$StatusIndex=Find-HeaderIndex $Headers @('status','queue_status','state')
if($IdIndex-lt 0 -or $StatusIndex-lt 0){throw 'QUEUE_COLUMNS_NOT_FOUND'}
[object[]]$Pending=@()
foreach($Entry in @($Snapshot.queue.rows)){[object[]]$Values=@($Entry.values);$Status=(Read-Value $Values $StatusIndex).ToUpperInvariant();if($Status-eq'PENDING'){$Pending+=,[pscustomobject]@{queue_id=(Read-Value $Values $IdIndex);row_number=[int]$Entry.sheet_row;status='PENDING';row=$Values}}}
$Selected=if($Pending.Count-gt 0){$Pending[0]}else{$null}
if($Mode-eq'STATUS'){Write-Host ('OK LAUNCHER mode=STATUS pending='+$Pending.Count+' health='+[string]$Metrics.metrics.operational_health+' pressure='+[double]$Metrics.metrics.human_pressure_score+' real_write=False');exit 0}
if(-not $Selected){Write-Host ('OK LAUNCHER mode='+$Mode+' selected=False reason=NO_PENDING_ITEMS real_write=False');exit 0}
if($Mode-eq'SELECT'){Write-Host ('OK LAUNCHER mode=SELECT selected=True queue_id='+[string]$Selected.queue_id+' row='+[int]$Selected.row_number+' status=PENDING real_write=False');exit 0}
$TargetStatus=switch($Decision){'APPROVE'{'APPROVED'};'REJECT'{'REJECTED'};'REQUEST_CHANGES'{'CHANGES_REQUESTED'}}
$Packet=[pscustomobject]@{schema='engremiat.sheets-operational-control-panel.launcher-packet.v1';ok=$true;mode='DRY_RUN_PREPARE';queue_id=[string]$Selected.queue_id;queue_row_number=[int]$Selected.row_number;queue_current_status='PENDING';decision=$Decision;queue_target_status=$TargetStatus;authorization_required=$true;authorization_granted=$false;real_execution_allowed=$false;engine_binding_required=$true;duplicate_policy='BLOCK';stale_state_policy='BLOCK';rollback_required=$true;real_sheet_write=$false}
$PacketPath=Join-Path $Reports 'sheets-operational-control-panel-launcher-packet.v1.json'
[IO.File]::WriteAllText($PacketPath,($Packet|ConvertTo-Json -Depth 100),[Text.UTF8Encoding]::new($false))
Write-Host ('OK LAUNCHER mode=PREPARE selected=True queue_id='+[string]$Selected.queue_id+' row='+[int]$Selected.row_number+' decision='+$Decision+' target_status='+$TargetStatus+' authorization_required=True real_write=False packet='+$PacketPath)
