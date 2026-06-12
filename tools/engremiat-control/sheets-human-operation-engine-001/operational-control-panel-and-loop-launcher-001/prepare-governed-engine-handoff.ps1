param([ValidateSet('APPROVE','REJECT','REQUEST_CHANGES')][string]$Decision='APPROVE',[switch]$Execute)
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.UTF8Encoding]::new()
$ModuleRoot=Split-Path -Parent $PSScriptRoot
$Reports=Join-Path $ModuleRoot 'reports'
$BindingPath=Join-Path $Reports 'sheets-operational-control-panel-engine-binding.v1.json'
$LauncherPacketPath=Join-Path $Reports 'sheets-operational-control-panel-launcher-packet.v1.json'
$HandoffPath=Join-Path $Reports 'sheets-operational-control-panel-engine-handoff.v1.json'
foreach($Path in @($BindingPath,$LauncherPacketPath)){if(-not(Test-Path $Path)){throw ('REQUIRED_EVIDENCE_MISSING_'+[IO.Path]::GetFileName($Path))}}
$Binding=Get-Content $BindingPath -Raw|ConvertFrom-Json
$Packet=Get-Content $LauncherPacketPath -Raw|ConvertFrom-Json
if(-not $Binding.ok -or -not $Packet.ok -or $Packet.mode-ne'DRY_RUN_PREPARE'){throw 'ENGINE_HANDOFF_INPUT_INVALID'}
if([string]$Packet.decision-ne$Decision){throw 'ENGINE_HANDOFF_DECISION_MISMATCH'}
if($Execute){if(-not $Binding.real_execution_binding_ready){throw 'REAL_EXECUTION_BLOCKED_DURABLE_ENGINE_ENTRYPOINT_NOT_READY'};throw 'REAL_EXECUTION_BLOCKED_USE_EXISTING_GOVERNED_ENGINE_ENTRYPOINT'}
$Handoff=[pscustomobject]@{schema='engremiat.sheets-operational-control-panel.engine-handoff.v1';ok=$true;mode='NO_WRITE_CONTROLLED_HANDOFF';queue_id=[string]$Packet.queue_id;queue_row_number=[int]$Packet.queue_row_number;queue_current_status=[string]$Packet.queue_current_status;decision=$Decision;queue_target_status=[string]$Packet.queue_target_status;engine_objective=[string]$Binding.engine_objective;workflow=$Binding.workflow.sequence;authorization_required=$true;authorization_granted=$false;real_execution_allowed=$false;adapter_can_execute_real_write=$false;duplicate_policy='BLOCK';stale_state_policy='BLOCK';rollback_required=$true;real_sheet_write=$false}
[IO.File]::WriteAllText($HandoffPath,($Handoff|ConvertTo-Json -Depth 100),[Text.UTF8Encoding]::new($false))
Write-Host ('OK ENGINE_ADAPTER mode=NO_WRITE_HANDOFF queue_id='+[string]$Packet.queue_id+' decision='+$Decision+' target_status='+[string]$Packet.queue_target_status+' authorization_required=True real_execution_allowed=False real_sheet_write=False handoff='+$HandoffPath)
