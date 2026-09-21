# Bitbucket Operations Reference

Commands and API protocols for Bitbucket Cloud and Bitbucket Data Center.

---

## 1. Authentication via App Passwords

Bitbucket uses **App Passwords** for programmatic API and Git transport access.

Required permissions for the App Password:
- **Repositories**: Read & Write
- **Pull requests**: Read & Write

### Encoding Basic Auth
```powershell
$username = "my-bitbucket-user"
$appPassword = (Get-Content $tokenPath).Trim()
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${appPassword}"))
$headers = @{
    "Authorization" = "Basic $base64Auth"
    "Accept" = "application/json"
}
```

---

## 2. Bitbucket Cloud REST API v2

### Create Repository
```powershell
$workspace = "my-workspace"
$repoSlug = "my-project"

$body = @{
    scm = "git"
    is_private = $true
    description = "Project description"
} | ConvertTo-Json

$repo = Invoke-RestMethod -Uri "https://api.bitbucket.org/2.0/repositories/$workspace/$repoSlug" -Headers $headers -Method Post -Body $body -ContentType "application/json"
```

### Create Pull Request
```powershell
$body = @{
    title = "feat: user notifications"
    source = @{
        branch = @{ name = "feat/notifications" }
    }
    destination = @{
        branch = @{ name = "main" }
    }
    description = "## Summary`nAdded notification listeners"
    close_source_branch = $true
} | ConvertTo-Json

$pr = Invoke-RestMethod -Uri "https://api.bitbucket.org/2.0/repositories/$workspace/$repoSlug/pullrequests" -Headers $headers -Method Post -Body $body -ContentType "application/json"
```

---

## 3. Ephemeral Safe Push Protocol for Bitbucket

```powershell
git remote add origin https://bitbucket.org/$workspace/$repoSlug.git 2>$null
git push "https://${username}:${appPassword}@bitbucket.org/$workspace/$repoSlug.git" main
git remote set-url origin "https://bitbucket.org/$workspace/$repoSlug.git"
```
