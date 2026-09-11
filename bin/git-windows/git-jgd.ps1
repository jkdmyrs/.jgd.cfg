[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Command,
    [Parameter(ValueFromRemainingArguments)] [string[]] $Arguments
)
$ErrorActionPreference = 'Stop'
function Invoke-Git([string[]] $GitArguments) {
    & git @GitArguments
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
# Runs git but doesn't halt the script on failure (e.g. branch not pushed yet)
function Invoke-GitOptional([string[]] $GitArguments) {
    & git @GitArguments
}
function Current-Branch { $branch = (& git branch --show-current).Trim(); if ($LASTEXITCODE -ne 0 -or -not $branch) { throw 'Not on a local branch.' }; $branch }
function Open-GitHubUrl([string] $Path) {
    $remote = (& git remote get-url origin).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Remote origin is not configured.' }
    $remote = $remote -replace '^git@github\.com:', 'https://github.com/' -replace '^https://github\.com/', 'https://github.com/' -replace '\.git$', ''
    Start-Process "$remote/$Path"
}

switch ($Command) {
    'cim' { Invoke-Git @('commit', '-m', ($Arguments -join ' ')) }
    'p' { $branch = Current-Branch; Invoke-Git @('push', '--set-upstream', 'origin', $branch) }
    'pr' { & $PSCommandPath p; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; $branch = Current-Branch; Open-GitHubUrl "pull/$branch" }
    'fresh' { Invoke-Git @('add', '--all'); Invoke-Git @('reset', '--hard'); Invoke-Git @('clean', '-dfx') }
    'fresher' {
        & $PSCommandPath fresh; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & $PSCommandPath latest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $branches = @(git branch --format='%(refname:short)' | Where-Object { $_ -ne 'main' })
        foreach ($branch in $branches) { Invoke-Git @('branch', '-D', $branch) }
    }
    'latest' { $branch = if ($Arguments.Count) { $Arguments[0] } else { 'main' }; Invoke-Git @('add', '--all'); Invoke-Git @('stash'); Invoke-Git @('checkout', $branch); Invoke-Git @('fetch', '--prune'); Invoke-Git @('pull', 'origin', $branch) }
    'new' { if (-not $Arguments.Count) { throw 'Usage: git new <branch> [base]' }; $newBranch = $Arguments[0]; $base = if ($Arguments.Count -gt 1) { $Arguments[1] } else { 'main' }; Invoke-Git @('add', '--all'); Invoke-Git @('stash'); Invoke-Git @('fetch'); Invoke-Git @('checkout', "origin/$base"); Invoke-Git @('checkout', '-b', $newBranch) }
    'get' { if (-not $Arguments.Count) { throw 'Usage: git get <branch>' }; Invoke-Git @('fetch', '--prune'); & git switch -t $Arguments[0] 2>$null; if ($LASTEXITCODE -ne 0) { Invoke-Git @('checkout', $Arguments[0]) } }
    'pick' { if (-not $Arguments.Count) { throw 'Usage: git pick <commit>' }; $branch = Current-Branch; Invoke-Git @('checkout', '-b', "pick$($Arguments[0])"); Invoke-Git @('cherry-pick', $Arguments[0]); & $PSCommandPath up $branch }
    'up' { $base = if ($Arguments.Count) { $Arguments[0] } else { 'main' }; & $PSCommandPath sync $base; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; & $PSCommandPath pr }
    'sync' { $base = if ($Arguments.Count) { $Arguments[0] } else { 'main' }; $branch = Current-Branch; Invoke-Git @('add', '--all'); Invoke-Git @('stash'); Invoke-Git @('fetch', '--prune'); Invoke-GitOptional @('pull', 'origin', $branch); Invoke-Git @('merge', "origin/$base") }
    'release' { Invoke-Git @('fetch', '--prune'); $tag = @(git tag -l '[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]*' | Sort-Object -Descending | Select-Object -First 1); if (-not $tag) { throw 'No tags found.' }; $target = if ($Arguments.Count) { $Arguments[0] } else { 'main' }; Open-GitHubUrl "compare/$tag...$target" }
    default { throw "Unknown git-jgd command: $Command" }
}
