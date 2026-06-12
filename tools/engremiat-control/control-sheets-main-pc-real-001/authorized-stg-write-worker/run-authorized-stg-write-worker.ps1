param([switch]$DryRun,[switch]$RealRun,[string]$AuthorizationPhrase='')
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
Set-Location $Root
$ExpectedAuth = 'SI, AUTORIZO IMPORT REAL STAGING CONTROL_SHEETS_MAIN_PC_REAL_001 SIN FINAL TABS SIN PUSH'
$Base = Join-Path $Root 'tools\engremiat-control\control-sheets-main-pc-real-001\authorized-stg-write-worker'
$PlanCsv = Join-Path $Base 'control-sheets-main-pc-real-001-authorized-stg-write-plan.v1.csv'
$RunReport = Join-Path $Base 'control-sheets-main-pc-real-001-authorized-stg-worker-run-report.v1.json'
if (-not (Test-Path $PlanCsv)) { throw "No existe write plan: $PlanCsv" }
$Plan = @(Import-Csv -Path $PlanCsv)
$Ready = @($Plan | Where-Object { $_.source_exists -eq 'True' })
$Missing = @($Plan | Where-Object { $_.source_exists -ne 'True' })
if ($RealRun -and $AuthorizationPhrase -ne $ExpectedAuth) {
  $Result = [pscustomobject]@{ ok=$false; decision='REAL_STG_WRITE_BLOCKED_AUTHORIZATION_MISMATCH'; mode='SAFE_BLOCK'; real_sheet_write=$false; google_api_call=$false; final_tabs_allowed=$false; push=$false; ready_tabs_count=$Ready.Count; missing_tabs_count=$Missing.Count }
  $Result | ConvertTo-Json -Depth 100 | Set-Content -Path $RunReport -Encoding UTF8
  Write-Host 'REAL_STG_WRITE_BLOCKED_AUTHORIZATION_MISMATCH' -ForegroundColor Red
  exit 1
}
if ($RealRun) {
  $Result = [pscustomobject]@{ ok=$false; decision='REAL_STG_WRITE_NOT_EXECUTED_GOOGLE_API_ADAPTER_PENDING_NEXT_STEP'; mode='REAL_AUTH_GRANTED_BUT_ADAPTER_PENDING'; real_sheet_write=$false; google_api_call=$false; final_tabs_allowed=$false; push=$false; ready_tabs_count=$Ready.Count; missing_tabs_count=$Missing.Count; recommended_next='STEP_006_ATTACH_GOOGLE_API_ADAPTER_AND_RUN_READONLY_PROBE_FIRST' }
  $Result | ConvertTo-Json -Depth 100 | Set-Content -Path $RunReport -Encoding UTF8
  Write-Host 'REAL_AUTH_GRANTED_BUT_GOOGLE_API_ADAPTER_PENDING_NO_WRITE_DONE' -ForegroundColor Yellow
  exit 0
}
$OkValue = ($Missing.Count -eq 0)
$Result = [pscustomobject]@{ ok=$OkValue; decision='AUTHORIZED_STG_WORKER_DRY_RUN_OK_NO_GOOGLE_API_NO_WRITE'; mode='DRY_RUN_ONLY'; target_tabs_count=$Plan.Count; ready_tabs_count=$Ready.Count; missing_tabs_count=$Missing.Count; final_tabs_allowed=$false; real_sheet_write=$false; google_api_call=$false; apps_script_execution=$false; push=$false; authorization_required_for_real_run=$true; recommended_next='STEP_006_ATTACH_GOOGLE_API_ADAPTER_AND_RUN_READONLY_PROBE_FIRST'; plan=$Plan }
$Result | ConvertTo-Json -Depth 100 | Set-Content -Path $RunReport -Encoding UTF8
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001_AUTHORIZED_STG_WORKER_DRY_RUN_BEGIN'
Write-Host "ok=$($Result.ok)"
Write-Host "decision=$($Result.decision)"
Write-Host "target_tabs_count=$($Result.target_tabs_count)"
Write-Host "ready_tabs_count=$($Result.ready_tabs_count)"
Write-Host "missing_tabs_count=$($Result.missing_tabs_count)"
Write-Host 'real_sheet_write=False'
Write-Host 'google_api_call=False'
Write-Host 'final_tabs_allowed=False'
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001_AUTHORIZED_STG_WORKER_DRY_RUN_END'
