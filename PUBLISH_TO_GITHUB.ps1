$ErrorActionPreference = 'Stop'

function Require-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found. Install it first (see README_GITHUB_PAGES.txt), reopen PowerShell, and retry."
    }
}

Require-Command 'git'
Require-Command 'gh'

$repoName = 'yourgym-website'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host 'GitHub CLI is not signed in. Starting the GitHub sign-in flow...' -ForegroundColor Yellow
    gh auth login
    if ($LASTEXITCODE -ne 0) { throw 'GitHub sign-in did not complete.' }
}

$account = gh api user --jq .login
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($account)) {
    throw 'Could not read the signed-in GitHub username. Run gh auth login and try again.'
}
$userId = gh api user --jq .id
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($userId)) {
    throw 'Could not read the GitHub account ID for a private noreply commit address.'
}
$fullRepo = "$account/$repoName"
Write-Host "Publishing website to https://github.com/$fullRepo" -ForegroundColor Cyan

if (-not (Test-Path (Join-Path $root '.git'))) {
    git init -b main
    if ($LASTEXITCODE -ne 0) { throw 'Could not initialize the local Git repository.' }
} else {
    git branch -M main
    if ($LASTEXITCODE -ne 0) { throw 'Could not set the local branch to main.' }
}

# Configure a privacy-preserving noreply commit identity if this new folder has none.
$gitName = git config user.name 2>$null
if ([string]::IsNullOrWhiteSpace(($gitName -join '').Trim())) {
    git config user.name $account
}
$gitEmail = git config user.email 2>$null
if ([string]::IsNullOrWhiteSpace(($gitEmail -join '').Trim())) {
    git config user.email "$userId+$account@users.noreply.github.com"
}

git add --all
if ($LASTEXITCODE -ne 0) { throw 'Git could not stage the website files.' }
git diff --cached --quiet
$hasChanges = ($LASTEXITCODE -eq 1)
if ($LASTEXITCODE -gt 1) { throw 'Git could not inspect staged changes.' }
if ($hasChanges) {
    git commit -m 'Publish YourGym.us website'
    if ($LASTEXITCODE -ne 0) { throw 'Git commit failed.' }
}

$repoExists = $true
gh repo view $fullRepo --json name | Out-Null
if ($LASTEXITCODE -ne 0) { $repoExists = $false }

if (-not $repoExists) {
    Write-Host 'Creating a new PUBLIC GitHub repository (required for free Pages hosting)...' -ForegroundColor Yellow
    gh repo create $repoName --public --source $root --remote origin --push
    if ($LASTEXITCODE -ne 0) { throw 'Could not create/push the GitHub repository.' }
} else {
    $visibility = gh repo view $fullRepo --json visibility --jq .visibility
    if ($LASTEXITCODE -ne 0) { throw 'Could not read repository visibility.' }
    if ($visibility -ne 'PUBLIC') {
        throw "The existing repository $fullRepo is $visibility. This publishing script will not change it to public automatically. Make it public in GitHub settings, or choose a different repository name."
    }
    $remote = git remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0) {
        git remote add origin "https://github.com/$fullRepo.git"
    } else {
        git remote set-url origin "https://github.com/$fullRepo.git"
    }
    if ($LASTEXITCODE -ne 0) { throw 'Could not configure the GitHub remote.' }
    git push -u origin main
    if ($LASTEXITCODE -ne 0) { throw 'Could not push the website to GitHub.' }
}

Write-Host ''
Write-Host 'Website files have been pushed successfully.' -ForegroundColor Green
Write-Host 'Next: configure GitHub Pages and the custom domain in the browser.' -ForegroundColor Cyan
Start-Process "https://github.com/$fullRepo/settings/pages"
Write-Host "Repository: https://github.com/$fullRepo"
Write-Host "Pages settings: https://github.com/$fullRepo/settings/pages"
Write-Host 'In Settings > Pages, select Deploy from a branch, main, /(root), then set custom domain to yourgym.us.'
