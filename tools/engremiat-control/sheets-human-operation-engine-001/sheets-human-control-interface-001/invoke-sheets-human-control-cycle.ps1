param(
    [ValidateSet('STATUS','PREPARE','DRY_RUN')] [string]$Mode = 'STATUS',
    [ValidateSet('APPROVE','REJECT','REQUEST_CHANGES')] [string]$Decision = 'APPROVE',
    [string]$QueueId = '',
    [string]$Reviewer = 'ENGREMIAT_HUMAN_OPERATOR',
    [string]$Comment = '',
    [string]$AuthorizationPhrase = '',
    [string]$InputPath = '',
    [string]$OutputPath = ''
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$interfaceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = Split-Path -Parent $interfaceDir
$entrypoint = Join-Path $module 'durable-governed-engine-entrypoint-001\invoke-governed-human-operation.ps1'
if(-not(Test-Path $entrypoint)){throw 'DURABLE_ENTRYPOINT_NOT_FOUND'}
if($Mode -eq 'STATUS'){& $entrypoint -Mode STATUS -OutputPath $OutputPath; if($LASTEXITCODE-ne 0){exit $LASTEXITCODE}; exit 0}
if(-not $InputPath -or -not(Test-Path $InputPath)){throw 'SHEETS_HUMAN_CONTROL_INPUT_REQUIRED'}
if(-not $QueueId){throw 'SHEETS_HUMAN_CONTROL_QUEUE_ID_REQUIRED'}
if(-not $Reviewer){throw 'SHEETS_HUMAN_CONTROL_REVIEWER_REQUIRED'}
$source=Get-Content $InputPath -Raw|ConvertFrom-Json
if($source.schema-ne'engremiat.sheets-human-control-interface.cycle-input.v1'){throw 'SHEETS_HUMAN_CONTROL_INPUT_SCHEMA_INVALID'}
$runInput=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.run-input.v1';reviewer=$Reviewer;comment=$Comment;created_at=(Get-Date).ToUniversalTime().ToString('o');queue=$source.queue;review=$source.review;history=$source.history}
$tmp=Join-Path $env:TEMP ('engremiat-sheets-human-control-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force|Out-Null
try {
$runInputPath=Join-Path $tmp 'run-input.json'
$runOutputPath=Join-Path $tmp 'run-output.json'
[IO.File]::WriteAllText($runInputPath,($runInput|ConvertTo-Json -Depth 100),[Text.UTF8Encoding]::new($false))
if($Mode -eq 'PREPARE'){$result=[pscustomobject]@{schema='engremiat.sheets-human-control-interface.prepare-result.v1';ok=$true;queue_id=$QueueId;decision=$Decision;reviewer=$Reviewer;comment_present=[bool]$Comment;run_input_ready=$true;entrypoint=$entrypoint;execution_allowed=$false;real_sheet_write=$false};$json=$result|ConvertTo-Json -Depth 100;if($OutputPath){[IO.File]::WriteAllText($OutputPath,$json,[Text.UTF8Encoding]::new($false))}else{Write-Output $json};exit 0}
& $entrypoint -Mode RUN -Decision $Decision -QueueId $QueueId -AuthorizationPhrase $AuthorizationPhrase -ExecutionMode DRY_RUN -InputPath $runInputPath -OutputPath $runOutputPath
if($LASTEXITCODE-ne 0){exit $LASTEXITCODE}
$result=Get-Content $runOutputPath -Raw|ConvertFrom-Json
$result|Add-Member -NotePropertyName interface_mode -NotePropertyValue 'DRY_RUN' -Force
$result|Add-Member -NotePropertyName refresh_required -NotePropertyValue $false -Force
$result|Add-Member -NotePropertyName real_sheet_write -NotePropertyValue $false -Force
$json=$result|ConvertTo-Json -Depth 100;if($OutputPath){[IO.File]::WriteAllText($OutputPath,$json,[Text.UTF8Encoding]::new($false))}else{Write-Output $json}
}
finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
