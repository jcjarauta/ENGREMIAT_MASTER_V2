$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$phase = "LEGACY_PC_002_CREATE_EXPORT_PACKAGE_AFTER_FREEZE"
$legacyRoot = "C:\Users\sacan\Desktop\ENGREMIAT_MASTER"
if(-not (Test-Path $legacyRoot)){ throw "No existe legacyRoot esperado: $legacyRoot" }

Set-Location $legacyRoot
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$outDir = Join-Path $legacyRoot "reports\migration-freeze-export"
$packageRoot = Join-Path $outDir "ENGREMIAT_LEGACY_EXPORT_PACKAGE_$ts"
$staging = Join-Path $packageRoot "payload"
New-Item -ItemType Directory -Force -Path $staging | Out-Null

$status = (& git status --short 2>&1) -join "`n"
$dirtyCount = 0
if(-not [string]::IsNullOrWhiteSpace($status)){ $dirtyCount = @($status -split "`n" | Where-Object { $_.Trim() -ne "" }).Count }

if($dirtyCount -gt 0){
  throw "Freeze bloqueado: hay cambios sin cerrar. dirty_count=$dirtyCount"
}

$exclude = @("\node_modules\", "\dist\", "\.tmp", "\reports\migration-freeze-export\ENGREMIAT_LEGACY_EXPORT_PACKAGE_")
$files = @(Get-ChildItem -Path $legacyRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
  $p = $_.FullName
  $skip = $false
  foreach($e in $exclude){ if($p -like "*$e*"){ $skip = $true } }
  -not $skip
})

foreach($f in $files){
  $rel = $f.FullName.Substring($legacyRoot.Length).TrimStart("\")
  $dest = Join-Path $staging $rel
  New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
  Copy-Item -Path $f.FullName -Destination $dest -Force
}

$manifestJson = Join-Path $packageRoot "PACKAGE_MANIFEST.json"
$manifestMd = Join-Path $packageRoot "PACKAGE_MANIFEST.md"
$sourceNode = Join-Path $packageRoot "SOURCE_NODE.txt"
$restore = Join-Path $packageRoot "RESTORE_INSTRUCTIONS.md"
$zipPath = "$packageRoot.zip"
$shaPath = Join-Path $packageRoot "SHA256SUMS.txt"

$head = (& git rev-parse --short HEAD 2>$null) -join ""
$branch = (& git branch --show-current 2>$null) -join ""

$manifest = [ordered]@{
  phase = $phase
  created_at = (Get-Date).ToString("s")
  source_node = "LEGACY_NODE"
  source_root = $legacyRoot
  branch = $branch
  head = $head
  files_count = @($files).Count
  dirty_count = $dirtyCount
  package_root = $packageRoot
  zip_path = $zipPath
}
$manifest | ConvertTo-Json -Depth 80 | Set-Content -Path $manifestJson -Encoding UTF8

Set-Content -Path $manifestMd -Encoding UTF8 -Value @(
"# PACKAGE_MANIFEST",
"",
"phase=$phase",
"source_node=LEGACY_NODE",
"source_root=$legacyRoot",
"branch=$branch",
"head=$head",
"files_count=$(@($files).Count)",
"dirty_count=$dirtyCount"
)

Set-Content -Path $sourceNode -Encoding UTF8 -Value @(
"source_node=LEGACY_NODE",
"source_root=$legacyRoot",
"branch=$branch",
"head=$head",
"created_at=$((Get-Date).ToString('s'))"
)

Set-Content -Path $restore -Encoding UTF8 -Value @(
"# RESTORE_INSTRUCTIONS",
"",
"1. Copiar zip a C:\ENGREMIAT\incoming en MAIN_NODE.",
"2. Validar SHA256.",
"3. Descomprimir en temp.",
"4. Revisar PACKAGE_MANIFEST.",
"5. Instalar en C:\ENGREMIAT\ENGREMIAT_MASTER solo tras validacion."
)

Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $zipPath -Force
$hash = Get-FileHash -Path $zipPath -Algorithm SHA256
Set-Content -Path $shaPath -Encoding UTF8 -Value "$($hash.Hash)  $(Split-Path $zipPath -Leaf)"

Write-Host "STATUS_FINAL_PARA_PEGAR"
Write-Host "phase=$phase"
Write-Host "ok=True"
Write-Host "decision=LEGACY_EXPORT_PACKAGE_CREATED_AFTER_FREEZE"
Write-Host "dirty_count=$dirtyCount"
Write-Host "files_count=$(@($files).Count)"
Write-Host "package_root=$packageRoot"
Write-Host "zip_path=$zipPath"
Write-Host "sha256=$($hash.Hash)"
Write-Host "recommended_next=transfer_zip_to_main_node_incoming"
