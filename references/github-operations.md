# GitHub Operations Reference

Comprehensive commands and API workflows for GitHub (GitHub.com and GitHub Enterprise Server).

---

## 1. Using GitHub CLI (`gh`)

When `gh` is installed and authenticated (`gh auth status` returns 0), prefer native CLI commands:

### Repository Management
```bash
# Create a new public repository from current directory and push
gh repo create my-project --public --source=. --remote=origin --push

# Create a private repository under an organization
gh repo create my-org/my-project --private --source=. --remote=origin --push

# Clone a repository
gh repo clone owner/repo
```

### Pull Request Automation
```bash
# Create a Pull Request with auto-filled title & body from commits
gh pr create --title "feat: add user authentication" --body "## Summary`n- Implemented JWT auth`n`n## Testing`n- Unit tests pass"

# View PR review status and checks
gh pr checks
gh pr view

# Merge a Pull Request (squash and delete branch)
gh pr merge --squash --delete-branch
```

### Releases & Tags
```bash
# Create a new release with generated release notes
gh release create v1.0.0 --title "v1.0.0 Initial Release" --generate-notes
```

---

## 2. Using REST API v3 (PowerShell & curl Fallback)

When `gh` is not installed, use GitHub REST API v3 with a Personal Access Token (PAT).

### Authenticate & Identify User
```powershell
$token = (Get-Content $tokenPath).Trim()
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-GitIntegration"
}
$user = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
$owner = $user.login
```

### Create Repository
```powershell
$body = @{
    name = "my-project"
    description = "Project description"
    private = $false
} | ConvertTo-Json

$repo = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers -Method Post -Body $body
```

### Create Pull Request
```powershell
$body = @{
    title = "feat: add feature"
    head = "feat/my-branch"
    base = "main"
    body = "## Summary`nImplemented new feature"
} | ConvertTo-Json

$pr = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/pulls" -Headers $headers -Method Post -Body $body
```

---

## 3. Ephemeral Safe Push Protocol

```powershell
$token = (Get-Content $tokenPath).Trim()
git remote add origin https://github.com/$owner/$repo.git 2>$null
git push "https://$token@github.com/$owner/$repo.git" main
git remote set-url origin "https://github.com/$owner/$repo.git"
```
