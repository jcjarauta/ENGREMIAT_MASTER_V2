$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$Root = "C:\Users\sacan\Desktop\ENGREMIAT_MASTER"
$OperatorRoot = Join-Path $Root "repos\engremiat-operator"
$RunsRoot = Join-Path $OperatorRoot "runs"
$OutboxPath = Join-Path $OperatorRoot ".operator\outbox\last-report.txt"
$DashboardData = Join-Path $Root "dashboard-master\data"
$MasterStatusPath = Join-Path $DashboardData "master-control-status.json"
$OllamaStatusPath = Join-Path $DashboardData "ollama-status.json"

New-Item -ItemType Directory -Force -Path $DashboardData | Out-Null

function Read-JsonSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  $Raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  if ([string]::IsNullOrWhiteSpace($Raw)) { return $null }
  return ($Raw | ConvertFrom-Json)
}

function Invoke-GitRead {
  param([string]$Repo,[string[]]$ArgsList)
  $Out = & git -C $Repo @ArgsList 2>&1
  return [pscustomobject]@{ code = $LASTEXITCODE; text = ($Out -join [Environment]::NewLine) }
}

function Get-ReportField {
  param([string]$Raw,[string]$Name)
  foreach ($Line in @($Raw -split "`r?`n")) {
    if ($Line.StartsWith($Name + "=")) { return $Line.Substring($Name.Length + 1).Trim() }
  }
  return ""
}

function Extract-ReportBlock {
  param([string]$Raw)
  if ([string]::IsNullOrWhiteSpace($Raw)) { return "" }
  $Begin = $Raw.IndexOf("# ENGREMIAT_REPORT_BEGIN")
  $EndMarker = "# ENGREMIAT_REPORT_END"
  if ($Begin -lt 0) { return "" }
  $End = $Raw.IndexOf($EndMarker, $Begin)
  if ($End -lt 0) { return "" }
  return $Raw.Substring($Begin, ($End + $EndMarker.Length - $Begin)).Trim()
}

function Find-ValidReportStdout {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return "" }
  $Files = Get-ChildItem -LiteralPath $Path -Filter "stdout.txt" -File -Recurse -Force -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
  foreach ($File in $Files | Select-Object -First 80) {
    if ($File.Length -le 0) { continue }
    $Raw = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
    if ($Raw.Contains("# ENGREMIAT_REPORT_BEGIN") -and $Raw.Contains("# ENGREMIAT_REPORT_END")) { return $File.FullName }
  }
  return ""
}

$NowIso = (Get-Date).ToString("o")
$OllamaStatus = Read-JsonSafe $OllamaStatusPath
$OutboxExists = Test-Path -LiteralPath $OutboxPath
$ReportRaw = ""
$ReportSource = "none"
$SourceStdoutPath = ""
$SourceRunPath = ""

if ($OutboxExists) {
  $ReportRaw = Get-Content -LiteralPath $OutboxPath -Raw -Encoding UTF8
  $ReportSource = "operator_outbox"
} else {
  $SourceStdoutPath = Find-ValidReportStdout -Path $RunsRoot
  if (-not [string]::IsNullOrWhiteSpace($SourceStdoutPath)) {
    $SourceRunPath = Split-Path -Parent $SourceStdoutPath
    $RawStdout = Get-Content -LiteralPath $SourceStdoutPath -Raw -Encoding UTF8
    $ReportRaw = Extract-ReportBlock -Raw $RawStdout
    $ReportSource = "runs_stdout_fallback"
  }
}

$ReportType = Get-ReportField -Raw $ReportRaw -Name "type"
$ReportOk = Get-ReportField -Raw $ReportRaw -Name "ok"
$ReportDecision = Get-ReportField -Raw $ReportRaw -Name "decision"
$GitStatus = Invoke-GitRead -Repo $Root -ArgsList @("status","--short")
$GitHead = Invoke-GitRead -Repo $Root -ArgsList @("rev-parse","--short","HEAD")
$RunCount = 0
if (Test-Path -LiteralPath $RunsRoot) { $RunCount = @(Get-ChildItem -LiteralPath $RunsRoot -Directory -Force -ErrorAction SilentlyContinue).Count }
$GitDirty = -not [string]::IsNullOrWhiteSpace($GitStatus.text)
$SelectedModel = ""
$OllamaOverall = ""
$OllamaGate = ""
if ($null -ne $OllamaStatus) {
  $SelectedModel = [string]$OllamaStatus.selected_local_model
  $OllamaOverall = [string]$OllamaStatus.overall_status
  $OllamaGate = [string]$OllamaStatus.gate
}

$Payload = [ordered]@{
  type = "MASTER_CONTROL_STATUS"
  ok = $true
  generated_at = $NowIso
  decision = "MASTER_CONTROL_STATUS_REFRESHED_WITH_RUNS_FALLBACK_NO_MODEL_EXEC"
  operator = [ordered]@{
    outbox_exists = $OutboxExists
    fallback_report_exists = (-not [string]::IsNullOrWhiteSpace($ReportRaw))
    report_source = $ReportSource
    outbox_path = $OutboxPath
    source_stdout_path = $SourceStdoutPath
    source_run_path = $SourceRunPath
    report_type = $ReportType
    ok = $ReportOk
    decision = $ReportDecision
    run_count = $RunCount
  }
  ollama = [ordered]@{
    status_json_exists = (Test-Path -LiteralPath $OllamaStatusPath)
    selected_local_model = $SelectedModel
    overall_status = $OllamaOverall
    gate = $OllamaGate
  }
  git = [ordered]@{
    head = if ($GitHead.code -eq 0) { $GitHead.text.Trim() } else { "" }
    dirty = $GitDirty
    status_short = $GitStatus.text
  }
  safety = [ordered]@{
    model_invocation_performed = $false
    pull_performed = $false
    push_performed = $false
    git_write_actions = $false
    browser_actions = $false
    clipboard_actions = $false
    telegram_real_actions = $false
    switch_off_confirmed = $true
  }
  next_recommended_action = "HYPER_089B3F_RUN_REFRESHER_WITH_FALLBACK_NO_MODEL_EXEC_001"
}

$Payload | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $MasterStatusPath -Encoding UTF8
$null = Get-Content -LiteralPath $MasterStatusPath -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "# ENGREMIAT_REPORT_BEGIN"
Write-Host "type=MASTER_CONTROL_STATUS_REFRESHER_RUNS_FALLBACK_RUN"
Write-Host "ok=True"
Write-Host "decision=MASTER_CONTROL_STATUS_REFRESHED_WITH_RUNS_FALLBACK_NO_MODEL_EXEC"
Write-Host "master_status_path=$MasterStatusPath"
Write-Host "operator_outbox_exists=$OutboxExists"
Write-Host "report_source=$ReportSource"
Write-Host "fallback_report_exists=$(-not [string]::IsNullOrWhiteSpace($ReportRaw))"
Write-Host "source_stdout_path=$SourceStdoutPath"
Write-Host "report_type=$ReportType"
Write-Host "report_decision=$ReportDecision"
Write-Host "model_invocation_performed=False"
Write-Host "pull_performed=False"
Write-Host "push_performed=False"
Write-Host "git_write_actions=False"
Write-Host "switch_off_confirmed=True"
Write-Host "# ENGREMIAT_REPORT_END"
