# ENGREMIAT REAL STAGING IMPORT WORKER - PREPARED ONLY
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
Set-Location $Root
$AuthorizationPhraseRequired = 'SI, AUTORIZO IMPORT STAGING CONTROL_SHEETS_MAIN_PC_REAL_001 SIN FINAL TABS SIN PUSH'
$AuthorizationPhraseProvided = Read-Host 'Pega frase exacta de autorizacion para ejecutar import staging real'
if ($AuthorizationPhraseProvided -ne $AuthorizationPhraseRequired) { throw 'AUTHORIZATION_PHRASE_MISMATCH_NO_EXECUTION' }
throw 'PREPARED_WORKER_ONLY_NOT_EXECUTABLE_IN_BLOCK_007_RUN_BLOCK_008_DECISION_FIRST'
