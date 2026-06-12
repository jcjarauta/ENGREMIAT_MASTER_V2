param(
    [ValidateSet('STATUS','RUN')] [string]$Mode = 'STATUS',
    [ValidateSet('APPROVE','REJECT','REQUEST_CHANGES')] [string]$Decision = 'APPROVE',
    [string]$QueueId = '',
    [string]$AuthorizationPhrase = '',
    [ValidateSet('DRY_RUN','SIMULATE_ATOMIC')] [string]$ExecutionMode = 'DRY_RUN',
    [string]$InputPath = '',
    [string]$OutputPath = ''
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$entryDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$selectorWorker = Join-Path $entryDir 'stable-selector-worker.js'
$payloadWorker = Join-Path $entryDir 'parameterized-payload-builder.js'
$preflightWorker = Join-Path $entryDir 'preflight-duplicate-guard.js'
$authorizationWorker = Join-Path $entryDir 'exact-authorization-gate.js'
$executorWorker = Join-Path $entryDir 'parameterized-atomic-executor.js'
foreach ($path in @($selectorWorker,$payloadWorker,$preflightWorker,$authorizationWorker,$executorWorker)) { if (-not (Test-Path $path)) { throw ('ENTRYPOINT_WORKER_MISSING_' + [IO.Path]::GetFileName($path)) } }
function Write-JsonResult { param([object]$Data,[string]$Path) $json=$Data|ConvertTo-Json -Depth 100; if($Path){[IO.File]::WriteAllText($Path,$json,[Text.UTF8Encoding]::new($false))}else{Write-Output $json} }
function Invoke-NodeJson {
    param([string]$Worker,[object]$Data,[string]$Name,[string]$WorkDir)
    $inputFile = Join-Path $WorkDir ($Name + '.in.json')
    $outputFile = Join-Path $WorkDir ($Name + '.out.json')
    $errorFile = Join-Path $WorkDir ($Name + '.err.json')
    [IO.File]::WriteAllText($inputFile,($Data|ConvertTo-Json -Depth 100),[Text.UTF8Encoding]::new($false))
    & cmd.exe /d /c ('node "'+$Worker+'" "'+$inputFile+'" 1>"'+$outputFile+'" 2>"'+$errorFile+'"') | Out-Null
    $exitCode = $LASTEXITCODE
    if($exitCode -ne 0){$message=if(Test-Path $errorFile){Get-Content $errorFile -Raw}else{''};throw ('ENTRYPOINT_WORKER_FAILED name=' + $Name + ' exit=' + $exitCode + ' error=' + $message)}
    if(-not(Test-Path $outputFile)){throw ('ENTRYPOINT_WORKER_OUTPUT_MISSING_' + $Name)}
    return ((Get-Content $outputFile -Raw).Trim() | ConvertFrom-Json)
}
if($Mode -eq 'STATUS'){Write-JsonResult -Data ([pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.status.v1';ok=$true;ready=$true;modes=@('STATUS','RUN');decisions=@('APPROVE','REJECT','REQUEST_CHANGES');execution_modes=@('DRY_RUN','SIMULATE_ATOMIC');real_sheet_write=$false}) -Path $OutputPath; exit 0}
if(-not $InputPath -or -not(Test-Path $InputPath)){throw 'ENTRYPOINT_INPUT_PATH_REQUIRED'}
$input = Get-Content $InputPath -Raw | ConvertFrom-Json
if($input.schema -ne 'engremiat.sheets-durable-governed-engine-entrypoint.run-input.v1'){throw 'ENTRYPOINT_RUN_INPUT_SCHEMA_INVALID'}
$work = Join-Path $env:TEMP ('engremiat-entrypoint-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null
try {
    $selectorInput=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.selector-input.v1';headers=@($input.queue.headers);rows=@($input.queue.rows);queue_id=$QueueId;pending_status='PENDING';require_pending=$true}
    $selected=Invoke-NodeJson -Worker $selectorWorker -Data $selectorInput -Name 'selector' -WorkDir $work
    if(-not $selected.selected){throw 'ENTRYPOINT_NO_PENDING_QUEUE_ITEM'}
    $payloadInput=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.payload-input.v1';selected_item=$selected.selected_item;decision=$Decision;reviewer=[string]$input.reviewer;created_at=[string]$input.created_at;queue_tab=[string]$input.queue.tab;review_tab=[string]$input.review.tab;history_tab=[string]$input.history.tab;review_headers=@($input.review.headers);history_headers=@($input.history.headers)}
    $payload=Invoke-NodeJson -Worker $payloadWorker -Data $payloadInput -Name 'payload' -WorkDir $work
    $preflightInput=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.preflight-input.v1';payload=$payload;queue_headers=@($input.queue.headers);queue_id_index=[int]$selected.queue_id_index;status_index=[int]$selected.status_index;queue_row=[pscustomobject]@{values=@($selected.selected_item.values)};review_rows=@($input.review.rows);history_rows=@($input.history.rows)}
    $preflight=Invoke-NodeJson -Worker $preflightWorker -Data $preflightInput -Name 'preflight' -WorkDir $work
    $phrase=if($AuthorizationPhrase){$AuthorizationPhrase}else{[string]$payload.authorization_phrase}
    $authorizationInput=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.authorization-input.v1';payload=$payload;preflight=$preflight;authorization_phrase=$phrase}
    $authorization=Invoke-NodeJson -Worker $authorizationWorker -Data $authorizationInput -Name 'authorization' -WorkDir $work
    $executorInput=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.executor-input.v1';mode=$ExecutionMode;payload=$payload;preflight=$preflight;authorization=$authorization;fixture_state=[pscustomobject]@{queue=[pscustomobject]@{queue_id=[string]$payload.queue.queue_id;status=[string]$payload.queue.current_status};review=@($input.review.rows);history=@($input.history.rows)};fail_after_mutation=0}
    $execution=Invoke-NodeJson -Worker $executorWorker -Data $executorInput -Name 'executor' -WorkDir $work
    $result=[pscustomobject]@{schema='engremiat.sheets-durable-governed-engine-entrypoint.run-result.v1';ok=$true;mode='RUN';decision=$Decision;execution_mode=$ExecutionMode;queue_id=[string]$payload.queue.queue_id;queue_row=[int]$payload.queue.row_number;queue_status_before=[string]$payload.queue.current_status;queue_status_after=[string]$payload.queue.target_status;review_id=[string]$payload.review.review_id;audit_id=[string]$payload.history.audit_id;selection_verified=$true;payload_verified=$true;preflight_verified=$true;authorization_verified=$true;execution_verified=[bool]$execution.ok;atomic_commit=[bool]$execution.atomic_commit;rollback_performed=[bool]$execution.rollback_performed;queue_verified=[bool]$execution.queue_verified;review_verified=[bool]$execution.review_verified;history_verified=[bool]$execution.history_verified;mutations_planned=[int]$execution.mutations_planned;mutations_applied=[int]$execution.mutations_applied;config_write=$false;real_sheet_write=$false}
    Write-JsonResult -Data $result -Path $OutputPath
}
finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
