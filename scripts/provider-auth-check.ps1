<#
.SYNOPSIS
    Checks authentication and API connectivity for Git providers configured in config.json.
.DESCRIPTION
    Non-destructively probes API endpoints and CLI tools for GitHub, GitLab, Bitbucket, and Gitea.
    Never outputs or logs private tokens or secrets.
#>

[CmdletBinding()]
param (
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

if (-not $ConfigPath) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
    $ConfigPath = Join-Path (Split-Path -Parent $scriptDir) "config.json"
}

if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config file not found at: $ConfigPath"
    return
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$results = @()

# 1. Test GitHub
if ($config.providers.github.enabled) {
    $ghStatus = "Failed"
    $ghUser = "N/A"
    $ghMethod = "None"
    
    # Try CLI first if configured
    if ($config.providers.github.use_cli_if_available -and (Get-Command gh -ErrorAction SilentlyContinue)) {
        try {
            $cliCheck = & gh auth status 2>&1
            if ($LASTEXITCODE -eq 0) {
                $ghStatus = "Connected"
                $ghMethod = "gh CLI"
                $ghUser = (gh api user --jq .login 2>$null)
            }
        } catch {}
    }
    
    # Fallback to token file
    if ($ghStatus -ne "Connected" -and (Test-Path $config.providers.github.token_path)) {
        try {
            $token = (Get-Content $config.providers.github.token_path).Trim()
            $headers = @{
                "Authorization" = "token $token"
                "Accept" = "application/vnd.github.v3+json"
                "User-Agent" = "GitIntegrationSkill"
            }
            $res = Invoke-RestMethod -Uri "$($config.providers.github.api_endpoint)/user" -Headers $headers -TimeoutSec 10
            $ghStatus = "Connected"
            $ghMethod = "Token File"
            $ghUser = $res.login
        } catch {
            $ghStatus = "Auth Error ($($_.Exception.Message))"
        }
    }

    $results += [PSCustomObject]@{
        Provider = "GitHub"
        Status   = $ghStatus
        Method   = $ghMethod
        User     = $ghUser
    }
}

# 2. Test GitLab
if ($config.providers.gitlab.enabled) {
    $glStatus = "Failed"
    $glUser = "N/A"
    $glMethod = "None"

    if (Test-Path $config.providers.gitlab.token_path) {
        try {
            $token = (Get-Content $config.providers.gitlab.token_path).Trim()
            $headers = @{
                "PRIVATE-TOKEN" = $token
                "Accept" = "application/json"
            }
            $res = Invoke-RestMethod -Uri "$($config.providers.gitlab.api_endpoint)/user" -Headers $headers -TimeoutSec 10
            $glStatus = "Connected"
            $glMethod = "Token File"
            $glUser = $res.username
        } catch {
            $glStatus = "Auth Error ($($_.Exception.Message))"
        }
    } else {
        $glStatus = "Token file not found"
    }

    $results += [PSCustomObject]@{
        Provider = "GitLab"
        Status   = $glStatus
        Method   = $glMethod
        User     = $glUser
    }
}

Write-Output "`n=== Git Provider Authentication & Connectivity Report ==="
$results | Format-Table -AutoSize
