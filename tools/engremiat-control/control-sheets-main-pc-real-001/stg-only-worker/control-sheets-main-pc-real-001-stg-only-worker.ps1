param([switch]$DryRun,[switch]$RealRun,[string]$AuthorizationPhrase='')
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
Set-Location $Root
$ExpectedAuth = 'SI, AUTORIZO IMPORT REAL STAGING CONTROL_SHEETS_MAIN_PC_REAL_001 SIN FINAL TABS SIN PUSH'
$ManifestPath = Join-Path $Root 'tools\engremiat-control\control-sheets-main-pc-real-001\stg-only-worker\control-sheets-main-pc-real-001-stg-only-worker-manifest.v1.csv'
$ReportPath = Join-Path $Root 'tools\engremiat-control\control-sheets-main-pc-real-001\stg-only-worker\control-sheets-main-pc-real-001-stg-only-worker-run-report.v1.json'
if (-not (Test-Path $ManifestPath)) { throw "No existe manifest: $ManifestPath" }
$Manifest = @(Import-Csv -Path $ManifestPath)
if ($RealRun -and $AuthorizationPhrase -ne $ExpectedAuth) {
  $Result = [pscustomobject]@{ ok=$false; decision='REAL_RUN_BLOCKED_AUTHORIZATION_MISMATCH'; real_sheet_write=$false; google_api_call=$false; final_tabs_allowed=$false; push=$false }
  $Result | ConvertTo-Json -Depth 100 | Set-Content -Path $ReportPath -Encoding UTF8
  Write-Host 'REAL_RUN_BLOCKED_AUTHORIZATION_MISMATCH' -ForegroundColor Red
  exit 1
}
if ($RealRun) {
  $Result = [pscustomobject]@{ ok=$false; decision='REAL_RUN_NOT_IMPLEMENTED_IN_DRY_RUN_WORKER_BUILD_NEXT_STEP_REQUIRED'; real_sheet_write=$false; google_api_call=$false; final_tabs_allowed=$false; push=$false; recommended_next='IMPLEMENT_GOOGLE_SHEETS_API_STG_ONLY_WRITE_WITH_ROW_AUDIT' }
  $Result | ConvertTo-Json -Depth 100 | Set-Content -Path $ReportPath -Encoding UTF8
  Write-Host 'REAL_RUN_NOT_IMPLEMENTED_IN_THIS_STEP' -ForegroundColor Yellow
  exit 0
}
$Ready = @($Manifest | Where-Object { $_.candidate_found -eq 'True' })
$Missing = @($Manifest | Where-Object { $_.candidate_found -ne 'True' })
$OkValue = ($Missing.Count -eq 0)
$Result = [pscustomobject]@{ ok=$OkValue; decision='STG_ONLY_WORKER_DRY_RUN_OK_NO_GOOGLE_API_NO_WRITE'; mode='DRY_RUN_ONLY'; target_tabs_count=$Manifest.Count; ready_tabs_count=$Ready.Count; missing_tabs_count=$Missing.Count; final_tabs_allowed=$false; real_sheet_write=$false; google_api_call=$false; apps_script_execution=$false; push=$false; recommended_next='IMPLEMENT_AUTHORIZED_GOOGLE_SHEETS_STG_ONLY_WRITE_STEP'; manifest=$Manifest }
$Result | ConvertTo-Json -Depth 100 | Set-Content -Path $ReportPath -Encoding UTF8
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001_STG_ONLY_WORKER_DRY_RUN_BEGIN'
Write-Host "ok=$($Result.ok)"
Write-Host "decision=$($Result.decision)"
Write-Host "target_tabs_count=$($Result.target_tabs_count)"
Write-Host "ready_tabs_count=$($Result.ready_tabs_count)"
Write-Host "missing_tabs_count=$($Result.missing_tabs_count)"
Write-Host 'real_sheet_write=False'
Write-Host 'google_api_call=False'
Write-Host 'final_tabs_allowed=False'
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001_STG_ONLY_WORKER_DRY_RUN_END'
