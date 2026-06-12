param()
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
Set-Location $Root
$AuthPhrase = 'SI, AUTORIZO IMPORT REAL STAGING CONTROL_SHEETS_MAIN_PC_REAL_001 SIN FINAL TABS SIN PUSH'
Write-Host ''
Write-Host '==============================================================================' -ForegroundColor Yellow
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001 · AUTHORIZED REAL STAGING IMPORT LAUNCHER' -ForegroundColor Yellow
Write-Host '==============================================================================' -ForegroundColor Yellow
Write-Host 'Este launcher esta preparado, pero NO ejecuta import real automaticamente.'
Write-Host 'Para ejecutar import real debera introducirse la frase exacta de autorizacion.'
Write-Host 'final_tabs_allowed=False'
Write-Host 'push=False'
Write-Host 'apps_script_execution=False'
Write-Host 'scope=STG_* only'
Write-Host ''
$Typed = Read-Host 'Pega la frase exacta de autorizacion o pulsa Enter para cancelar'
if ($Typed -ne $AuthPhrase) {
  Write-Host 'AUTHORIZATION_NOT_GRANTED_IMPORT_CANCELLED' -ForegroundColor Red
  Write-Host 'real_sheet_write=False'
  Write-Host 'google_api_call=False'
  exit 0
}
Write-Host 'AUTHORIZATION_GRANTED_BUT_WORKER_REAL_STILL_NOT_IMPLEMENTED_IN_THIS_SAFE_PACKAGE' -ForegroundColor Yellow
Write-Host 'decision=READY_FOR_NEXT_STEP_BUILD_MINIMAL_GOOGLE_WORKER_STG_ONLY'
Write-Host 'real_sheet_write=False'
Write-Host 'google_api_call=False'
Write-Host 'recommended_next=BUILD_MINIMAL_GOOGLE_SHEETS_STG_ONLY_WORKER_WITH_AUDIT_AND_ROW_COUNTS'
