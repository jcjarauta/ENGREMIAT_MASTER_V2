$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:GIT_PAGER = 'cat'
Set-Location 'C:\ENGREMIAT_REPO_CLEAN\ENGREMIAT_MASTER_V2'
git add -- 'tools/engremiat-control/control-sheets-main-pc-real-001'
if ($LASTEXITCODE -ne 0) { throw 'GIT_ADD_SCOPED_FAILED' }
git commit -m 'close control sheets main pc real 001 local evidence'
if ($LASTEXITCODE -ne 0) { throw 'GIT_COMMIT_FAILED' }
git status --short
if ($LASTEXITCODE -ne 0) { throw 'GIT_STATUS_AFTER_COMMIT_FAILED' }
