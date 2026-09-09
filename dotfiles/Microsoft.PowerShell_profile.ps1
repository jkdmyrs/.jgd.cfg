$ErrorActionPreference = 'Stop'

$jgdRoot = if ($env:JGD_ROOT) { $env:JGD_ROOT } else { 'D:\.jgd.cfg' }
$env:JGD_ROOT = $jgdRoot
$env:Path = "$(Join-Path $jgdRoot 'bin\git-windows');$env:Path"
$env:DENO_INSTALL = if ($env:DENO_INSTALL) { $env:DENO_INSTALL } else { Join-Path $HOME '.deno' }
$env:Path = "$(Join-Path $env:DENO_INSTALL 'bin');$env:Path"
if (Test-Path (Join-Path $HOME 'dotnet')) { $env:Path = "$(Join-Path $HOME 'dotnet');$env:Path" }
$env:EDITOR = 'vim'

$env:USR_DIR = if ($env:USR_DIR) { $env:USR_DIR } else { Join-Path $HOME '' }
$env:PRJ_DIR = 'D:\'
$env:WEG_DIR = 'D:\wegmans'
$env:SAP_DIR = Join-Path $env:WEG_DIR 'sap'
$env:DIS_DIR = Join-Path $env:SAP_DIR 'sap-disintegrator'
$env:LOC_DIR = Join-Path $env:SAP_DIR 'locations-hub'
$env:ADMIN_DIR = Join-Path $env:SAP_DIR 'sap-integration-management'
$env:EL_DIR = Join-Path $env:WEG_DIR 'enterprise-library'
$env:DOCS_DIR = Join-Path $env:WEG_DIR 'docs.wegmans.tech'
$env:CLOUD_DIR = Join-Path $env:WEG_DIR 'cloud-events'
$env:COST_DIR = Join-Path $env:SAP_DIR 'cost-service'
$env:BRICKS_DIR = Join-Path $env:SAP_DIR 'fps-databricks'

function Set-LocationIfExists([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) { Write-Warning "Path does not exist: $Path"; return }
    Set-Location -LiteralPath $Path
}
function ll { Get-ChildItem -Force | Format-Table -AutoSize }
function brc { . $PROFILE }
function code { $codeCommand = Get-Command code -CommandType Application -ErrorAction Stop; & $codeCommand.Source . @args }
function vs { & psrun (Get-ChildItem -Filter '*.sln' | Select-Object -First 1).FullName @args }
function explore { Start-Process explorer.exe (Get-Location) }
function jgd { Set-LocationIfExists $env:JGD_ROOT }
function prj { Set-LocationIfExists $env:PRJ_DIR }
function usr { Set-LocationIfExists $env:USR_DIR }
function dsk { Set-LocationIfExists (Join-Path $env:USR_DIR 'Desktop') }
function dwn { Set-LocationIfExists (Join-Path $env:USR_DIR 'Downloads') }
function weg { Set-LocationIfExists $env:WEG_DIR }
function sap { Set-LocationIfExists $env:SAP_DIR }
function dis { $env:PROJECT_ROOT = $env:DIS_DIR; Set-LocationIfExists $env:PROJECT_ROOT }
function loc { $env:PROJECT_ROOT = $env:LOC_DIR; Set-LocationIfExists $env:PROJECT_ROOT }
function admin { $env:PROJECT_ROOT = $env:ADMIN_DIR; Set-LocationIfExists $env:PROJECT_ROOT }
function el { Set-LocationIfExists $env:EL_DIR }
function cloud { Set-LocationIfExists $env:CLOUD_DIR }
function docs { Set-LocationIfExists $env:DOCS_DIR }
function cost { Set-LocationIfExists $env:COST_DIR }
function bricks { $env:PROJECT_ROOT = $env:BRICKS_DIR; Set-LocationIfExists $env:PROJECT_ROOT }
function jsonlint([string] $Path) { Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json | Out-Null }
function token([ValidateSet('dis', 'disProd')] [string] $Name) {
    $resources = @{ dis = 'c8304276-f3c4-40eb-acfb-d2330f4578a9'; disProd = 'b40ad62d-c014-4401-80aa-cab6adabb233' }
    & az account get-access-token --resource $resources[$Name] --tenant '1318d57f-757b-45b3-b1b0-9b3c3842774f'
}
function copilot_env { & powershell.exe (Join-Path $env:WEG_DIR 'sap\sap-disintegrator\tools\Set-McpToken.ps1') }
function copilot_gh { & copilot.exe @args }
function copilot { copilot_env; if ($LASTEXITCODE -eq 0) { copilot_gh @args } }
function greeting { Write-Output 'Hello Jack!'; Write-Output '' }

function prompt {
    $escape = [char]27
    $location = (Get-Location).Path
    $line = "${escape}[32m$location${escape}[0m"
    $branch = (& git branch --show-current 2>$null).Trim()
    if ($LASTEXITCODE -eq 0) {
        $commit = (& git log -1 --format='%h%x09%an%x09%s' 2>$null) -split "`t", 3
        $aheadBehind = & git rev-list --left-right --count '@{u}...HEAD' 2>$null
        $tracking = if ($LASTEXITCODE -eq 0) { "`n     $([char]0x2191)$($aheadBehind -split '\s+')[1]  $([char]0x2193)$($aheadBehind -split '\s+')[0]" } else { '' }
        $line += "`n     ${escape}[33m($branch@$($commit[0]))${escape}[37m $($commit[2]) ${escape}[34m<$($commit[1])>${escape}[0m$tracking"
    }
    "$line`n`$ "
}

$ohMyPoshTheme = Join-Path $env:JGD_ROOT 'dotfiles\jgd.omp.json'
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $ohMyPoshTheme)) {
    $ohMyPoshShell = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'powershell' }
    oh-my-posh init $ohMyPoshShell --config $ohMyPoshTheme | Invoke-Expression

    # oh-my-posh's git segment only exposes aggregate change counts, not per-file
    # status lines, so splice real `git status` output between the branch and
    # prompt-marker lines by keeping a live reference to its prompt function.
    $global:__ompPrompt = $Function:prompt
    function prompt {
        $line = & $global:__ompPrompt
        if ($line.Contains(' * ')) {
            $status = & git -c color.status=always status --short 2>$null
            if ($LASTEXITCODE -eq 0 -and $status) {
                $statusBlock = ($status | ForEach-Object { "  $_" }) -join "`n"
                $marker = "`n`$ "
                $idx = $line.LastIndexOf($marker)
                if ($idx -ge 0) {
                    $line = $line.Substring(0, $idx) + "`n" + $statusBlock + $marker
                }
            }
        }
        $line
    }
}
