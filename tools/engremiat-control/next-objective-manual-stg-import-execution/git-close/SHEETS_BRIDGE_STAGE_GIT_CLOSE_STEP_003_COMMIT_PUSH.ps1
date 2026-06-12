param()

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:GIT_PAGER = 'cat'

$Root = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
$FilesListPath = 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2\tools\engremiat-control\next-objective-manual-stg-import-execution\git-close\SHEETS-BRIDGE-GIT-CLOSE-DRY-RUN-20260612-060444.files-list.txt'
$ExpectedHead = '03fe72d'
$ExpectedBranch = 'main'
$CommitMessage = 'close sheets bridge independence and manual stg validation'

Write-Host 'STEP_003_PREPARED_NOT_EXECUTED_BY_DRY_RUN'
Write-Host ('root=' + $Root)
Write-Host ('files_list=' + $FilesListPath)
Write-Host ('expected_head=' + $ExpectedHead)
Write-Host ('expected_branch=' + $ExpectedBranch)
Write-Host ('commit_message=' + $CommitMessage)
