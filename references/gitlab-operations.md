# GitLab Operations Reference

Comprehensive commands and API workflows for GitLab (GitLab.com and self-hosted GitLab CE/EE instances).

---

## 1. Using GitLab CLI (`glab`)

When `glab` is installed and authenticated (`glab auth status` returns 0), prefer native CLI commands:

### Repository Management
```bash
# Create a new public repository and push current directory
glab repo create my-project --public --push

# Create under a group / namespace
glab repo create my-group/my-project --private --push

# Clone a repository
glab repo clone my-group/my-project
```

### Merge Request (MR) Automation
```bash
# Create a Merge Request targeting the default branch
glab mr create --title "feat: implement reporting module" --description "## Summary`nAdded report generation" --remove-source-branch

# View pipeline and MR status
glab mr view
glab ci status

# Merge MR
glab mr merge --squash --remove-source-branch
```

---

## 2. Using GitLab REST API v4 (PowerShell Fallback)

When `glab` is not available, use the GitLab REST API v4 with a Personal Access Token (`api` scope).

### Authenticate & Identify User
```powershell
$token = (Get-Content $tokenPath).Trim()
$headers = @{
    "PRIVATE-TOKEN" = $token
    "Accept" = "application/json"
}
$endpoint = "https://gitlab.com/api/v4" # Or your self-hosted URL

$user = Invoke-RestMethod -Uri "$endpoint/user" -Headers $headers
$username = $user.username
```

### Create Project
```powershell
$body = @{
    name = "my-project"
    visibility = "public" # or "private", "internal"
    initialize_with_readme = $false
} | ConvertTo-Json

$project = Invoke-RestMethod -Uri "$endpoint/projects" -Headers $headers -Method Post -Body $body -ContentType "application/json"
$projectId = $project.id
```

### Create Merge Request
```powershell
$body = @{
    source_branch = "feat/my-branch"
    target_branch = "main"
    title = "feat: add payment gateway"
    description = "## Summary`nAdded Stripe integration"
    remove_source_branch = $true
} | ConvertTo-Json

$mr = Invoke-RestMethod -Uri "$endpoint/projects/$projectId/merge_requests" -Headers $headers -Method Post -Body $body -ContentType "application/json"
```

---

## 3. Ephemeral Safe Push Protocol for GitLab

```powershell
$token = (Get-Content $tokenPath).Trim()
# For GitLab, authentication via HTTPS uses username 'oauth2' or token name:
git remote add origin https://gitlab.com/$namespace/$repo.git 2>$null
git push "https://oauth2:$token@gitlab.com/$namespace/$repo.git" main
git remote set-url origin "https://gitlab.com/$namespace/$repo.git"
```
