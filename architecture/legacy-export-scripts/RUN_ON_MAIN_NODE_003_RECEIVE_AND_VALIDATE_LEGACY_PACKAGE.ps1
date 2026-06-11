$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$phase = "MAIN_NODE_003_RECEIVE_AND_VALIDATE_LEGACY_PACKAGE"
$incoming = "C:\ENGREMIAT\incoming"
$temp = "C:\ENGREMIAT\temp\legacy-package-validation"
New-Item -ItemType Directory -Force -Path $incoming,$temp | Out-Null

$zip = Get-ChildItem -Path $incoming -Filter "ENGREMIAT_LEGACY_EXPORT_PACKAGE_*.zip" -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if(-not $zip){ throw "No se encontro paquete zip en $incoming" }

$hash = Get-FileHash -Path $zip.FullName -Algorithm SHA256
$extract = Join-Path $temp ($zip.BaseName + "_extract")
if(Test-Path $extract){ Remove-Item -Path $extract -Recurse -Force }
New-Item -ItemType Directory -Force -Path $extract | Out-Null

Expand-Archive -Path $zip.FullName -DestinationPath $extract -Force

$manifest = Get-ChildItem -Path $extract -Filter "PACKAGE_MANIFEST.json" -Recurse -File | Select-Object -First 1
$payload = Get-ChildItem -Path $extract -Directory -Recurse | Where-Object { $_.Name -eq "payload" } | Select-Object -First 1

$ok = ($manifest -ne $null -and $payload -ne $null)
$decision = "LEGACY_PACKAGE_VALIDATED_READY_FOR_INSTALL_REVIEW"
if(-not $ok){ $decision = "LEGACY_PACKAGE_INVALID_REVIEW_REQUIRED" }

Write-Host "STATUS_FINAL_PARA_PEGAR"
Write-Host "phase=$phase"
Write-Host "ok=$ok"
Write-Host "decision=$decision"
Write-Host "zip=$($zip.FullName)"
Write-Host "sha256=$($hash.Hash)"
Write-Host "extract=$extract"
Write-Host "manifest_found=$([bool]$manifest)"
Write-Host "payload_found=$([bool]$payload)"
Write-Host "repo_install_executed=False"
Write-Host "recommended_next=install_validated_package_to_main_repo_target_after_review"
