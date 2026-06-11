# ENGREMIAT_BEGIN
$ErrorActionPreference = "Stop"
$root = "C:\Users\sacan\Desktop\ENGREMIAT_MASTER"
$base = Join-Path $root "tools\engremiat-constructor"
$statusPath = Join-Path $base "control\constructor_status.json"
$status = Get-Content -Path $statusPath -Raw | ConvertFrom-Json
if (-not $status.ok) { throw "Constructor status no ok" }
if ($status.status -ne "GENERATED_PROJECT_VALIDATED") { throw "Estado inesperado: $($status.status)" }
Write-Host "LOG: ok=True | script=validate-generated-project.ps1 | project=$($status.generated_project_id) | status=$($status.status)"
# ENGREMIAT_END
