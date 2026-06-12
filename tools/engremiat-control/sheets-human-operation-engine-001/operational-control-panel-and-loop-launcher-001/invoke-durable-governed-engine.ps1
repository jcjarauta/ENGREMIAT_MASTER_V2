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
$module = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$entrypoint = Join-Path $module 'durable-governed-engine-entrypoint-001\invoke-governed-human-operation.ps1'
if(-not(Test-Path $entrypoint)){throw 'DURABLE_ENTRYPOINT_NOT_FOUND'}
& $entrypoint -Mode $Mode -Decision $Decision -QueueId $QueueId -AuthorizationPhrase $AuthorizationPhrase -ExecutionMode $ExecutionMode -InputPath $InputPath -OutputPath $OutputPath
if($LASTEXITCODE -ne 0){exit $LASTEXITCODE}
