# Gitea & Forgejo Operations Reference

Commands and REST API protocols for Gitea and Forgejo self-hosted instances.

---

## 1. Authentication & Endpoint Configuration

Gitea and Forgejo share the same REST API v1 specification.

```powershell
$token = (Get-Content $tokenPath).Trim()
$endpoint = "https://gitea.yourcompany.com/api/v1"

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/json"
}

# Verify authentication
$user = Invoke-RestMethod -Uri "$endpoint/user" -Headers $headers
$username = $user.username
```

---

## 2. API v1 Workflows

### Create Repository
```powershell
$body = @{
    name = "my-project"
    description = "Self-hosted repository"
    private = $true
    auto_init = $false
} | ConvertTo-Json

$repo = Invoke-RestMethod -Uri "$endpoint/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json"
```

### Create Pull Request
```powershell
$body = @{
    base = "main"
    head = "feat/new-endpoint"
    title = "feat: add user query endpoint"
    body = "## Summary`nAdded GET /users query"
} | ConvertTo-Json

$pr = Invoke-RestMethod -Uri "$endpoint/repos/$username/my-project/pulls" -Headers $headers -Method Post -Body $body -ContentType "application/json"
```

---

## 3. Ephemeral Safe Push Protocol

```powershell
$token = (Get-Content $tokenPath).Trim()
git remote add origin https://$host/$username/$repo.git 2>$null
git push "https://$token@$host/$username/$repo.git" main
git remote set-url origin "https://$host/$username/$repo.git"
```
