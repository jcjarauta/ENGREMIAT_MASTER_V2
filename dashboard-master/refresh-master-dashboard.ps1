$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$Root = "C:\Users\sacan\Desktop\ENGREMIAT_MASTER"
$DashboardRoot = Join-Path $Root "dashboard-master"
$UpdateScriptPath = Join-Path $DashboardRoot "update-master-control-status.ps1"
$DashboardIndexPath = Join-Path $DashboardRoot "index.html"
$MasterControlStatusPath = Join-Path $DashboardRoot "data\master-control-status.json"
$ReportRoot = Join-Path $Root "data\drive-db-sim\MASTER_DASHBOARD_REFRESH_PIPELINE_RUNTIME"
$RunId = "refresh-" + (Get-Date -Format "yyyyMMdd-HHmmss-fff")
$RunRoot = Join-Path $ReportRoot $RunId
$AuditDir = Join-Path $RunRoot "audit"
New-Item -ItemType Directory -Force -Path $RunRoot, $AuditDir | Out-Null

function Read-JsonStrict {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { throw "Missing JSON: $Path" }
  $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  if ([string]::IsNullOrWhiteSpace($raw)) { throw "Empty JSON: $Path" }
  return ($raw | ConvertFrom-Json)
}

if (-not (Test-Path -LiteralPath $UpdateScriptPath)) { throw "Missing update script: $UpdateScriptPath" }
if (-not (Test-Path -LiteralPath $DashboardIndexPath)) { throw "Missing dashboard index: $DashboardIndexPath" }

$IndexBeforeInfo = Get-Item -LiteralPath $DashboardIndexPath
$IndexBeforeLength = $IndexBeforeInfo.Length
$IndexBeforeWriteTime = $IndexBeforeInfo.LastWriteTimeUtc

$RunOut = & powershell -NoProfile -ExecutionPolicy Bypass -File $UpdateScriptPath 2>&1
$RunCode = $LASTEXITCODE
$RunText = ($RunOut -join [Environment]::NewLine)
if ($RunCode -ne 0) { throw "update-master-control-status.ps1 failed: $RunText" }

$IndexAfterInfo = Get-Item -LiteralPath $DashboardIndexPath
$IndexTouched = ($IndexBeforeLength -ne $IndexAfterInfo.Length -or $IndexBeforeWriteTime -ne $IndexAfterInfo.LastWriteTimeUtc)
if ($IndexTouched) { throw "Dashboard index was touched by refresh pipeline" }

$MasterStatus = Read-JsonStrict $MasterControlStatusPath
if ($MasterStatus.ok -ne $true) { throw "master-control-status.json ok is not true" }
if ($MasterStatus.safety.model_invocation_performed -ne $false) { throw "Unexpected model invocation flag" }
if ($MasterStatus.safety.pull_performed -ne $false) { throw "Unexpected pull flag" }
if ($MasterStatus.safety.push_performed -ne $false) { throw "Unexpected push flag" }
if ($MasterStatus.safety.git_write_actions -ne $false) { throw "Unexpected git write flag" }
if ($MasterStatus.safety.switch_off_confirmed -ne $true) { throw "Switch OFF not confirmed" }

$NowIso = (Get-Date).ToString("o")
$Audit = [ordered]@{
  type = "MASTER_DASHBOARD_REFRESH_PIPELINE_RUNTIME_AUDIT"
  ok = $true
  generated_at = $NowIso
  run_id = $RunId
  update_script_path = $UpdateScriptPath
  master_control_status_path = $MasterControlStatusPath
  dashboard_index_touched = $IndexTouched
  update_exitcode = $RunCode
  update_stdout = $RunText
  operator_outbox_exists = [bool]$MasterStatus.operator.outbox_exists
  run_count = [int]$MasterStatus.operator.run_count
  git_dirty = [bool]$MasterStatus.git.dirty
  model_invocation_performed = $false
  pull_performed = $false
  push_performed = $false
  git_write_actions = $false
  browser_actions = $false
  clipboard_actions = $false
  telegram_real_actions = $false
  switch_off_confirmed = $true
}

$Summary = [ordered]@{
  type = "MASTER_DASHBOARD_REFRESH_PIPELINE_RUNTIME_SUMMARY"
  ok = $true
  decision = "MASTER_DASHBOARD_REFRESH_PIPELINE_RUN_OK_NO_MODEL_EXEC"
  generated_at = $NowIso
  run_id = $RunId
  run_root = $RunRoot
  master_control_status_path = $MasterControlStatusPath
  dashboard_index_touched = $IndexTouched
  operator_outbox_exists = [bool]$MasterStatus.operator.outbox_exists
  run_count = [int]$MasterStatus.operator.run_count
  git_dirty = [bool]$MasterStatus.git.dirty
  model_invocation_performed = $false
  pull_performed = $false
  push_performed = $false
  git_write_actions = $false
  switch_off_confirmed = $true
}

$AuditPath = Join-Path $AuditDir "audit.json"
$SummaryPath = Join-Path $RunRoot "summary.json"
$Audit | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $AuditPath -Encoding UTF8
$Summary | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8

Write-Host "# ENGREMIAT_REPORT_BEGIN"
Write-Host "type=MASTER_DASHBOARD_REFRESH_PIPELINE_RUN"
Write-Host "ok=True"
Write-Host "decision=MASTER_DASHBOARD_REFRESH_PIPELINE_RUN_OK_NO_MODEL_EXEC"
Write-Host "run_id=$RunId"
Write-Host "run_root=$RunRoot"
Write-Host "summary_path=$SummaryPath"
Write-Host "audit_path=$AuditPath"
Write-Host "master_control_status_path=$MasterControlStatusPath"
Write-Host "dashboard_index_touched=$IndexTouched"
Write-Host "operator_outbox_exists=$($MasterStatus.operator.outbox_exists)"
Write-Host "run_count=$($MasterStatus.operator.run_count)"
Write-Host "git_dirty=$($MasterStatus.git.dirty)"
Write-Host "model_invocation_performed=False"
Write-Host "pull_performed=False"
Write-Host "push_performed=False"
Write-Host "git_write_actions=False"
Write-Host "switch_off_confirmed=True"
Write-Host "# ENGREMIAT_REPORT_END"
