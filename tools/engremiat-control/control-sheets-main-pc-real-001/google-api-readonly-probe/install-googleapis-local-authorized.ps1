param()
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
Set-Location $Root
Write-Host 'CONTROL_SHEETS_MAIN_PC_REAL_001 · INSTALL GOOGLEAPIS LOCAL AUTHORIZED' -ForegroundColor Yellow
Write-Host 'Esto puede usar red y modificar node_modules/package-lock. Ejecutar solo si lo autorizas.'
$Typed = Read-Host 'Escribe SI, AUTORIZO NPM INSTALL GOOGLEAPIS LOCAL para continuar'
if ($Typed -ne 'SI, AUTORIZO NPM INSTALL GOOGLEAPIS LOCAL') { Write-Host 'NPM_INSTALL_CANCELLED'; exit 0 }
npm install googleapis --save
if ($LASTEXITCODE -ne 0) { throw 'npm install googleapis fallo' }
Write-Host 'GOOGLEAPIS_INSTALL_DONE'
