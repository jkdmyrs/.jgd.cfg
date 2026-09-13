[CmdletBinding()]
param([switch] $Force, [switch] $Quick)
$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Item -LiteralPath $PSScriptRoot).FullName
$profileSource = Join-Path $repoRoot 'dotfiles\Microsoft.PowerShell_profile.ps1'
$profileTargets = @(
    $PROFILE,
    (Join-Path $HOME 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'),
    (Join-Path $HOME 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique
$gitBin = Join-Path $repoRoot 'bin\git-windows'

if ($Quick) {
    Write-Output 'Skipping winget installs (-Quick specified).'
} elseif (Get-Command winget -ErrorAction SilentlyContinue) {
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        winget install --id JanDeDobbeleer.OhMyPosh --exact --source winget --accept-source-agreements --accept-package-agreements
    }
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh font install CascadiaCode
    }
    if (-not (Get-Command wezterm.exe -ErrorAction SilentlyContinue)) {
        winget install --id wez.wezterm --exact --source winget --accept-source-agreements --accept-package-agreements
    }
} else {
    Write-Warning 'winget was not found; install Oh My Posh and WezTerm manually to enable the enhanced prompt and persistent Windows sessions.'
}

$marker = '# jgd.cfg PowerShell profile'
$profileHook = ". '$profileSource'"
foreach ($profileTarget in $profileTargets) {
    New-Item -ItemType Directory -Force -Path (Split-Path $profileTarget) | Out-Null
    if (-not (Test-Path $profileTarget)) { New-Item -ItemType File -Path $profileTarget | Out-Null }
    $profileText = Get-Content -Raw -LiteralPath $profileTarget
    if ($null -eq $profileText) { $profileText = '' }
    if ($profileText -notmatch [regex]::Escape($marker)) {
        Add-Content -LiteralPath $profileTarget -Value "`n$marker`n$profileHook`n"
    } elseif ($Force) {
        $profileText = [regex]::Replace($profileText, '(?m)^# jgd\.cfg PowerShell profile\r?\n[^\r\n]*(?:\r?\n|$)', "$marker`n$profileHook`n")
        Set-Content -LiteralPath $profileTarget -Value $profileText -NoNewline
    }
}
[Environment]::SetEnvironmentVariable('JGD_ROOT', $repoRoot, 'User')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $gitBin) { [Environment]::SetEnvironmentVariable('Path', "$gitBin;$userPath", 'User') }
$dispatcher = Join-Path $gitBin 'git-jgd.ps1'
$gitCommands = @('cim', 'fresh', 'fresher', 'get', 'latest', 'new', 'p', 'pick', 'pr', 'release', 'sync', 'up')
$gitConfigSource = Join-Path $repoRoot 'dotfiles\.gitconfig'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git was not found on PATH.' }
if (-not (Test-Path -LiteralPath $gitConfigSource)) { throw "Tracked Git config was not found: $gitConfigSource" }
$gitAliases = & git config --file $gitConfigSource --get-regexp '^alias\.'
if ($LASTEXITCODE -ne 0) { throw "Could not read aliases from $gitConfigSource" }
foreach ($gitAlias in $gitAliases) {
    $aliasName, $aliasValue = $gitAlias -split '\s+', 2
    & git config --global "alias.$($aliasName -replace '^alias\.', '')" $aliasValue
    if ($LASTEXITCODE -ne 0) { throw "Could not configure Git alias: $aliasName" }
}
& git config --global --unset-all alias.update
if ($LASTEXITCODE -notin 0, 5) { throw 'Could not remove legacy Git alias: update' }
foreach ($gitCommand in $gitCommands) {
    $aliasValue = "!pwsh.exe -NoProfile -ExecutionPolicy Bypass -File '$dispatcher' $gitCommand"
    & git config --global "alias.$gitCommand" $aliasValue
    if ($LASTEXITCODE -ne 0) { throw "Could not configure Git alias: $gitCommand" }
}
Write-Output "Installed jgd.cfg PowerShell profile at:"
$profileTargets | ForEach-Object { Write-Output "  $_" }
Write-Output "Git command aliases configured; open a new PowerShell session to refresh PATH."
