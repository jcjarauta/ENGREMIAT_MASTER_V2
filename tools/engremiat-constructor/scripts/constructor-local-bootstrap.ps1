# ENGREMIAT_BEGIN
$ErrorActionPreference = "Stop"
$root = "C:\Users\sacan\Desktop\ENGREMIAT_MASTER"
$base = Join-Path $root "tools\engremiat-constructor"
$projectPath = Join-Path $base "projects\generated\engremiat-training-game-inclusion-001\ENGREMIAT_PROJECT.json"
if (-not (Test-Path -Path $projectPath)) { throw "No existe proyecto bootstrap esperado: $projectPath" }
$project = Get-Content -Path $projectPath -Raw | ConvertFrom-Json
if ($project.status -ne "BOOTSTRAPPED") { throw "Estado inesperado: $($project.status)" }
Write-Host "LOG: ok=True | script=constructor-local-bootstrap.ps1 | project=$($project.project_id) | status=$($project.status)"
# ENGREMIAT_END
