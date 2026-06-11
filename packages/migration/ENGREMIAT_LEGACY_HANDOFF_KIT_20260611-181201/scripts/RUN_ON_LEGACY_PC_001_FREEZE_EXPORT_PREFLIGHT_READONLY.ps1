$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$phase = "LEGACY_PC_001_FREEZE_EXPORT_PREFLIGHT_READONLY"
$legacyRoot = "C:\Users\sacan\Desktop\ENGREMIAT_MASTER"
if(-not (Test-Path $legacyRoot)){ throw "No existe legacyRoot esperado: $legacyRoot" }

Set-Location $legacyRoot
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$outDir = Join-Path $legacyRoot "reports\migration-freeze-export"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$reportTxt = Join-Path $outDir "legacy-freeze-export-preflight-$ts.txt"
$reportJson = Join-Path $outDir "legacy-freeze-export-preflight-$ts.json"

function GitOut([string[]]$Args){
  try {
    $out = & git @Args 2>&1
    return [ordered]@{ ok=($LASTEXITCODE -eq 0); exit_code=$LASTEXITCODE; output=($out -join "`n") }
  } catch {
    return [ordered]@{ ok=$false; exit_code=-1; output=$_.Exception.Message }
  }
}

$status = GitOut @("status","--short")
$branch = GitOut @("branch","--show-current")
$head = GitOut @("rev-parse","--short","HEAD")
$log = GitOut @("log","--oneline","-10")
$remote = GitOut @("remote","-v")

$files = @(Get-ChildItem -Path $legacyRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
  $_.FullName -notmatch "\\.git\\" -and
  $_.FullName -notmatch "\\node_modules\\" -and
  $_.FullName -notmatch "\\dist\\" -and
  $_.FullName -notmatch "\\.tmp"
})

$totalBytes = [int64]0
foreach($f in $files){ $totalBytes += [int64]$f.Length }

$largeFiles = @($files | Sort-Object Length -Descending | Select-Object -First 20 | ForEach-Object {
  [ordered]@{
    path = $_.FullName.Substring($legacyRoot.Length).TrimStart("\")
    size_mb = [Math]::Round($_.Length / 1MB, 3)
  }
})

$dirtyCount = 0
if(-not [string]::IsNullOrWhiteSpace($status.output)){ $dirtyCount = @($status.output -split "`n" | Where-Object { $_.Trim() -ne "" }).Count }

$freezeReady = ($status.ok -and $head.ok)
$decision = "LEGACY_PREFLIGHT_READY_REVIEW_STATUS"
if($dirtyCount -gt 0){ $decision = "LEGACY_PREFLIGHT_READY_WITH_UNCOMMITTED_CHANGES_REVIEW_REQUIRED" }

$summary = [ordered]@{
  phase = $phase
  ok = $true
  decision = $decision
  legacy_root = $legacyRoot
  git_write = $false
  push = $false
  export_created = $false
  freeze_declared = $false
  branch = $branch.output.Trim()
  head = $head.output.Trim()
  dirty_count = $dirtyCount
  files_count = @($files).Count
  size_mb = [Math]::Round($totalBytes / 1MB, 3)
  large_files_top20 = $largeFiles
  status = $status.output
  log = $log.output
  remote = $remote.output
  report_txt = $reportTxt
  report_json = $reportJson
  recommended_next = "review_dirty_status_then_declare_freeze_or_commit_on_legacy"
}

$summary | ConvertTo-Json -Depth 100 | Set-Content -Path $reportJson -Encoding UTF8

$txt = @(
"phase=$phase",
"ok=True",
"decision=$decision",
"legacy_root=$legacyRoot",
"git_write=False",
"push=False",
"export_created=False",
"freeze_declared=False",
"branch=$($branch.output.Trim())",
"head=$($head.output.Trim())",
"dirty_count=$dirtyCount",
"files_count=$(@($files).Count)",
"size_mb=$([Math]::Round($totalBytes / 1MB, 3))",
"STATUS_BEGIN",
$status.output,
"STATUS_END",
"LOG_BEGIN",
$log.output,
"LOG_END",
"REMOTE_BEGIN",
$remote.output,
"REMOTE_END",
"LARGE_FILES_TOP20_BEGIN"
)
foreach($lf in $largeFiles){
  $txt += "path=$($lf.path); size_mb=$($lf.size_mb)"
}
$txt += "LARGE_FILES_TOP20_END"
$txt += "report_json=$reportJson"
$txt += "report_txt=$reportTxt"
$txt += "recommended_next=review_dirty_status_then_declare_freeze_or_commit_on_legacy"

Set-Content -Path $reportTxt -Value $txt -Encoding UTF8

Write-Host "STATUS_FINAL_PARA_PEGAR"
Get-Content -Path $reportTxt -Encoding UTF8
