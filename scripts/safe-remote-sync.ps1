<#
.SYNOPSIS
    Pushes to a Git remote safely using an in-memory token, immediately scrubbing the remote URL.
.DESCRIPTION
    Guarantees that credentials are never persisted in .git/config on disk.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$RemoteUrl,

    [Parameter(Mandatory = $true)]
    [string]$Branch,

    [Parameter(Mandatory = $true)]
    [string]$TokenPath,

    [ValidateSet("github", "gitlab", "bitbucket", "gitea")]
    [string]$Provider = "github",

    [string]$Username = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TokenPath)) {
    Write-Error "Token file not found: $TokenPath"
    return
}

$token = (Get-Content $TokenPath).Trim()

# Construct ephemeral push URL
$parsedUri = [System.Uri]$RemoteUrl
$hostName = $parsedUri.Host
$pathAndQuery = $parsedUri.PathAndQuery.TrimStart('/')

switch ($Provider) {
    "github" {
        $pushUrl = "https://${token}@${hostName}/${pathAndQuery}"
    }
    "gitlab" {
        $pushUrl = "https://oauth2:${token}@${hostName}/${pathAndQuery}"
    }
    "bitbucket" {
        if (-not $Username) { Write-Error "Username is required for Bitbucket basic auth"; return }
        $pushUrl = "https://${Username}:${token}@${hostName}/${pathAndQuery}"
    }
    "gitea" {
        $pushUrl = "https://${token}@${hostName}/${pathAndQuery}"
    }
}

try {
    Write-Host "Safely pushing to $RemoteUrl on branch $Branch..."
    git push $pushUrl $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git push failed with exit code $LASTEXITCODE"
    } else {
        Write-Host "Push successful!"
    }
} finally {
    # Ensure remote URL is strictly sanitized back to clean HTTPS
    git remote set-url origin $RemoteUrl 2>$null
    Write-Host "Remote URL sanitized: origin -> $RemoteUrl"
}
