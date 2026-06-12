param()
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
Set-Location $Root
$Auth = 'SI, AUTORIZO READONLY PROBE GOOGLE SHEETS CONTROL_SHEETS_MAIN_PC_REAL_001 SIN WRITE SIN FINAL TABS SIN PUSH'
$Adapter = Join-Path $Root 'tools\engremiat-control\control-sheets-main-pc-real-001\google-api-readonly-probe\google-sheets-stg-readonly-probe.js'
Write-Host ''
Write-Host '==============================================================================' -ForegroundColor Yellow
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001 · AUTHORIZED READONLY PROBE REAL' -ForegroundColor Yellow
Write-Host '==============================================================================' -ForegroundColor Yellow
Write-Host 'Solo lectura de metadatos/tabs. No escribe Sheets. No toca tabs finales. No push.'
Write-Host 'real_sheet_write=False'
Write-Host 'final_tabs_allowed=False'
Write-Host 'push=False'
$Typed = Read-Host 'Pega la frase exacta de autorizacion o pulsa Enter para cancelar'
if ($Typed -ne $Auth) { Write-Host 'READONLY_PROBE_CANCELLED_NO_API_CALL' -ForegroundColor Red; exit 0 }
& node $Adapter --real-readonly --authorization $Typed
if ($LASTEXITCODE -ne 0) { throw 'readonly probe fallo o quedo bloqueado de forma segura' }
