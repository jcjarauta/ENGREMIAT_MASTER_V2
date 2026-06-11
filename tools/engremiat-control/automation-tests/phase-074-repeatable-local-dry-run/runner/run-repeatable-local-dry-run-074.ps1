param(
  [string]$SeedPath = '',
  [string]$OutputRoot = '',
  [string]$RunId = ''
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
function TS($v) {
  if ($null -eq $v) { return '' }
  if ($v -is [array]) { return (($v | ForEach-Object { [string]$_ }) -join "`n") }
  return [string]$v
}
function EnsureDir($path) {
  if (-not (Test-Path -Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
}
function SaveJson($path, $obj) {
  EnsureDir (Split-Path -Parent $path)
  $json = $obj | ConvertTo-Json -Depth 100
  Set-Content -Path $path -Value $json -Encoding UTF8
  $null = Get-Content -Path $path -Raw -Encoding UTF8 | ConvertFrom-Json
}
$root = 'C:\Users\sacan\Desktop\ENGREMIAT_MASTER'
Set-Location $root
if ([string]::IsNullOrWhiteSpace($RunId)) { $RunId = 'repeatable-' + (Get-Date -Format 'yyyyMMdd-HHmmss') }
if ([string]::IsNullOrWhiteSpace($SeedPath)) { $SeedPath = Join-Path $root 'tools\engremiat-control\automation-tests\phase-074-repeatable-local-dry-run\examples\example_seed_preventa_digital_074.json' }
if ([string]::IsNullOrWhiteSpace($OutputRoot)) { $OutputRoot = Join-Path $root ('tools\engremiat-control\automation-tests\repeatable-runs\' + $RunId) }
EnsureDir $OutputRoot
if (-not (Test-Path -Path $SeedPath)) { throw ('SeedPath no existe: ' + $SeedPath) }
$seed = Get-Content -Path $SeedPath -Raw -Encoding UTF8 | ConvertFrom-Json
$safety = [ordered]@{}
$safety.real_ai_call_executed = $false
$safety.external_api_call_executed = $false
$safety.worker_real_execution_allowed = $false
$safety.operator_execution_allowed = $false
$safety.automation_real_execution_allowed = $false
$safety.repeatable_local_dry_run_only = $true
$safety.human_review_required = $true
$ideaTitle = TS $seed.idea_title
$targetUser = TS $seed.target_user
$problem = TS $seed.user_problem
$solution = TS $seed.proposed_solution
$productType = TS $seed.digital_product_type
$financeReason = TS $seed.why_financiable_or_presellable
$idea = [ordered]@{}
$idea.type = 'ENGREMIAT_REPEATABLE_F001_IDEA_INTAKE_DRY_RUN'
$idea.ok = $true
$idea.run_id = $RunId
$idea.source_seed_path = $SeedPath
$idea.idea_title = $ideaTitle
$idea.status = 'PASSED_DRY_RUN'
$idea.safety = $safety
SaveJson (Join-Path $OutputRoot '01_idea_intake_status.json') $idea
$packet = [ordered]@{}
$packet.type = 'ENGREMIAT_REPEATABLE_F002_NORMALIZED_PROJECT_PACKET_DRY_RUN'
$packet.ok = $true
$packet.run_id = $RunId
$packet.project_title = $ideaTitle
$packet.problem = $problem
$packet.solution = $solution
$packet.target_user = $targetUser
$packet.product_type = $productType
$packet.financing_or_presell_reason = $financeReason
$packet.status = 'NORMALIZED_DRY_RUN_NO_AI_CALL'
$packet.safety = $safety
SaveJson (Join-Path $OutputRoot '02_normalized_project_packet.json') $packet
$score = 70
if (-not [string]::IsNullOrWhiteSpace($ideaTitle)) { $score += 5 }
if (-not [string]::IsNullOrWhiteSpace($problem)) { $score += 5 }
if (-not [string]::IsNullOrWhiteSpace($solution)) { $score += 5 }
if (-not [string]::IsNullOrWhiteSpace($financeReason)) { $score += 5 }
if (@($seed.constraints).Count -ge 5) { $score += 5 }
if ($score -gt 100) { $score = 100 }
$level = 'medium'
if ($score -ge 85) { $level = 'high' }
$readiness = [ordered]@{}
$readiness.type = 'ENGREMIAT_REPEATABLE_F003_READINESS_GATE_DRY_RUN'
$readiness.ok = $true
$readiness.run_id = $RunId
$readiness.readiness_score = $score
$readiness.readiness_level = $level
$readiness.execution_allowed = $false
$readiness.status = 'PASSED_FOR_DRAFT_ROUTING_ONLY'
$readiness.safety = $safety
SaveJson (Join-Path $OutputRoot '03_readiness_gate.json') $readiness
$routes = @('WORKER_PROMPTER', 'WORKER_CONTROL_GATE', 'WORKER_MARKET_PREVENTA', 'WORKER_FINANCING', 'WORKER_OPENDATA', 'WORKER_VALIDATOR', 'WORKER_DASHBOARD')
$routing = [ordered]@{}
$routing.type = 'ENGREMIAT_REPEATABLE_F004_WORKER_ROUTING_DRAFT_DRY_RUN'
$routing.ok = $true
$routing.run_id = $RunId
$routing.worker_real_execution_allowed = $false
$routing.worker_routes = $routes
$routing.safety = $safety
SaveJson (Join-Path $OutputRoot '04_worker_routing_draft.json') $routing
$signalsNeeded = @('target_user_pain', 'preventa_interest', 'financing_fit', 'local_value', 'similar_solutions', 'minimum_offer')
$signals = [ordered]@{}
$signals.type = 'ENGREMIAT_REPEATABLE_F005_SIGNALS_NEEDED_CONTRACT_DRY_RUN'
$signals.ok = $true
$signals.run_id = $RunId
$signals.external_api_call_executed = $false
$signals.signals_needed = $signalsNeeded
$signals.safety = $safety
SaveJson (Join-Path $OutputRoot '05_signals_needed_contract.json') $signals
$packets = @('problem_definition', 'offer_draft', 'signals_plan', 'validation_gate', 'dashboard_summary')
$micro = [ordered]@{}
$micro.type = 'ENGREMIAT_REPEATABLE_F006_MICRO_WORK_PACKETS_DRY_RUN'
$micro.ok = $true
$micro.run_id = $RunId
$micro.micro_packet_count = 5
$micro.micro_packets_executable = $false
$micro.packets = $packets
$micro.safety = $safety
SaveJson (Join-Path $OutputRoot '06_micro_work_packets_index.json') $micro
$gate = [ordered]@{}
$gate.type = 'ENGREMIAT_REPEATABLE_F007_HUMAN_REVIEW_GATE_DRY_RUN'
$gate.ok = $true
$gate.run_id = $RunId
$gate.human_review_required = $true
$gate.selected_decision = 'HOLD'
$gate.execution_allowed = $false
$gate.safety = $safety
SaveJson (Join-Path $OutputRoot '07_human_review_gate.json') $gate
$html = @()
$html += '<!doctype html>'
$html += '<html lang="es">'
$html += '<head><meta charset="utf-8"><title>ENGREMIAT Repeatable Dry Run</title></head>'
$html += '<body>'
$html += '<h1>ENGREMIAT Repeatable Local Dry Run</h1>'
$html += ('<p>RunId=' + $RunId + '</p>')
$html += '<p>local_html_only=True</p>'
$html += '<p>NO_AI_CALL - NO_WORKER - NO_OPERATOR</p>'
$html += ('<p>Readiness=' + [string]$score + ' / ' + $level + '</p>')
$html += '</body>'
$html += '</html>'
Set-Content -Path (Join-Path $OutputRoot '08_repeatable_dry_run_dashboard.html') -Value $html -Encoding UTF8
$report = [ordered]@{}
$report.type = 'ENGREMIAT_REPEATABLE_LOCAL_DRY_RUN_REPORT_001'
$report.ok = $true
$report.run_id = $RunId
$report.output_root = $OutputRoot
$report.seed_path = $SeedPath
$report.dry_run_only = $true
$report.functions_validated = 8
$report.readiness_score = $score
$report.readiness_level = $level
$report.real_ai_call_executed = $false
$report.external_api_call_executed = $false
$report.worker_real_execution_allowed = $false
$report.operator_execution_allowed = $false
$report.automation_real_execution_allowed = $false
$report.next_recommended_action = 'START_PHASE_075_RUN_REPEATABLE_LOCAL_DRY_RUN_WITH_PARAMETERIZED_SEED_NO_REAL_AUTOMATION'
SaveJson (Join-Path $OutputRoot '09_repeatable_local_dry_run_report.json') $report
Write-Host '# ENGREMIAT_REPORT_BEGIN'
Write-Host 'type=ENGREMIAT_REPEATABLE_LOCAL_DRY_RUN_REPORT_001'
Write-Host 'ok=True'
Write-Host ('run_id=' + $RunId)
Write-Host ('output_root=' + $OutputRoot)
Write-Host 'dry_run_only=True'
Write-Host 'functions_validated=8'
Write-Host ('readiness_score=' + [string]$score)
Write-Host ('readiness_level=' + $level)
Write-Host 'real_ai_call_executed=False'
Write-Host 'external_api_call_executed=False'
Write-Host 'worker_real_execution_allowed=False'
Write-Host 'operator_execution_allowed=False'
Write-Host 'automation_real_execution_allowed=False'
Write-Host 'next_recommended_action=START_PHASE_075_RUN_REPEATABLE_LOCAL_DRY_RUN_WITH_PARAMETERIZED_SEED_NO_REAL_AUTOMATION'
Write-Host '# ENGREMIAT_REPORT_END'
