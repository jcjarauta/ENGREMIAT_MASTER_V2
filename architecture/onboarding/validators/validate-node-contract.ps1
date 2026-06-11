param(
  [Parameter(Mandatory=$true)]
  [string]$ContractPath
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

if(-not (Test-Path $ContractPath)){
  throw "Contrato no encontrado: $ContractPath"
}

$contract = Get-Content -Path $ContractPath -Raw -Encoding UTF8 | ConvertFrom-Json
$required = @(
  "node_id",
  "machine_name",
  "role",
  "root_path",
  "status",
  "allowed_actions",
  "blocked_actions",
  "sync_policy",
  "backup_policy",
  "secrets_policy",
  "activation_gate"
)

$missing = @()
foreach($field in $required){
  if(-not ($contract.PSObject.Properties.Name -contains $field)){
    $missing += $field
  }
}

$allowedStatus = @("PLANNED","PREPARED","READONLY_VALIDATED","ACTIVE","SUSPENDED","LEGACY")
$allowedGate = @("READONLY_PREFLIGHT_REQUIRED","MANUAL_APPROVAL_REQUIRED","ACTIVE_AFTER_VALIDATION")

$warnings = @()
if($allowedStatus -notcontains $contract.status){ $warnings += "invalid_status=$($contract.status)" }
if($allowedGate -notcontains $contract.activation_gate){ $warnings += "invalid_activation_gate=$($contract.activation_gate)" }
if($contract.secrets_policy.print_secrets -eq $true){ $warnings += "unsafe_secrets_policy_print_secrets_true" }
if(@($contract.blocked_actions).Count -eq 0){ $warnings += "blocked_actions_empty" }

$ok = (@($missing).Count -eq 0 -and @($warnings | Where-Object { $_ -like "invalid_*" -or $_ -like "unsafe_*" }).Count -eq 0)

Write-Host "ENGREMIAT_NODE_CONTRACT_VALIDATION_BEGIN"
Write-Host "contract=$ContractPath"
Write-Host "ok=$ok"
Write-Host "node_id=$($contract.node_id)"
Write-Host "status=$($contract.status)"
Write-Host "activation_gate=$($contract.activation_gate)"
Write-Host "missing=$($missing -join ',')"
Write-Host "warnings=$($warnings -join ',')"
Write-Host "ENGREMIAT_NODE_CONTRACT_VALIDATION_END"

if(-not $ok){ exit 1 }
exit 0
