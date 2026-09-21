# Authentication Matrix & Zero-Leak Credential Protocols

This reference details how to authenticate Git operations across different environments while strictly preventing credential leakage in command output, logs, or `.git/config`.

---

## 1. Credential Resolution Ladder

When performing authenticated actions, follow this hierarchy:

```
Step 1: Check CLI Tools (gh / glab)
        ├── If 'gh auth status' or 'glab auth status' returns 0 -> Use CLI tool directly
        └── If not authenticated -> Proceed to Step 2

Step 2: Check SSH Keys
        ├── Check if remote is 'git@<host>:...' or 'ssh -T git@<host>' succeeds
        ├── If SSH succeeds -> Use native SSH transport
        └── If SSH is not configured -> Proceed to Step 3

Step 3: Check Git Credential Manager (GCM)
        ├── Run 'git credential fill' or let Git prompt native OS keychain
        └── If GCM is not configured/headless -> Proceed to Step 4

Step 4: Configured Token File (Ephemeral Memory Load)
        ├── Read token dynamically from path specified in config.json
        ├── Load into temporary PowerShell / Bash variable
        └── Execute operation and sanitize immediately
```

---

## 2. Zero-Leak Token Hygiene

### The Golden Rules
1. **Never print tokens to console**: Avoid `echo $token` or displaying response bodies containing raw tokens.
2. **Never persist tokens in `.git/config`**:
   - ❌ **DANGEROUS**: `git remote set-url origin https://ghp_xxxx@github.com/user/repo.git`
   - ✅ **SAFE**: Pass token ephemerally during push or reset remote immediately:
     ```powershell
     # In PowerShell:
     $token = (Get-Content $tokenPath).Trim()
     git push "https://$token@github.com/$owner/$repo.git" $branch
     git remote set-url origin "https://github.com/$owner/$repo.git"
     ```
3. **Always scrub git remote on failure**: Wrap remote commands in `try/finally` blocks so that if an error occurs during push, the remote URL is still scrubbed clean.

---

## 3. Provider Authentication Endpoints & Headers

| Provider | Auth Header Format | Token Scopes Needed |
| :--- | :--- | :--- |
| **GitHub** | `Authorization: token <token>` or `Bearer <token>` | `repo`, `workflow`, `read:org` |
| **GitLab** | `PRIVATE-TOKEN: <token>` | `api`, `read_repository`, `write_repository` |
| **Bitbucket** | Basic Auth: `username:app_password` | `Repositories: Read & Write`, `Pull requests: Read & Write` |
| **Gitea / Forgejo** | `Authorization: token <token>` | `repo`, `user` |

---

## 4. SSH Setup Reference

For SSH workflows:
```bash
# Test GitHub SSH connectivity
ssh -T git@github.com

# Test GitLab SSH connectivity
ssh -T git@gitlab.com

# Configure an SSH remote
git remote set-url origin git@github.com:<owner>/<repo>.git
```
