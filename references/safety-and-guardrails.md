# Safety & Guardrails Reference

Essential safety protocols to prevent accidental data loss, secret leaks, and production branch disruption.

---

## 1. Protected Branch Safeguard

Protected branches (e.g. `main`, `master`, `production`, `staging`, `release`):
- **Never push directly to a protected branch** unless explicitly requested by the user.
- **Never run raw `git push --force`** on any remote branch.
- If rewriting history on a feature branch, **always use `git push --force-with-lease`**.
- When merging into a protected branch, prefer Pull Requests / Merge Requests so CI checks run.

---

## 2. Pre-Commit Secret Guardrail

Before running `git commit`, scan the staged changes:

```powershell
# Check for risky file names
$riskyFiles = git diff --cached --name-only | Select-String -Pattern "(token|credential|secret|\.env|id_rsa|\.pem|key\.json)"
if ($riskyFiles) {
    Write-Warning "BLOCKED: The following sensitive files are staged for commit:"
    $riskyFiles | ForEach-Object { Write-Warning "  - $_" }
    Write-Warning "Unstage them with: git reset HEAD <file> and add them to .gitignore"
}
```

Common patterns blocked:
- `*.env`, `.env.*`
- `*Token*.txt`, `*AccessToken*`
- `*Credentials*.txt`, `*Secret*`
- `id_rsa`, `id_ed25519`, `*.pem`, `*.key`

---

## 3. Merge Conflict Protocol

When rebasing a feature branch (`git rebase origin/main`):
1. If conflicts arise, Git pauses:
   ```bash
   git status
   ```
2. Inspect conflicting files, resolve conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
3. Stage the resolved files:
   ```bash
   git add <resolved-file>
   ```
4. Continue the rebase:
   ```bash
   git rebase --continue
   ```
5. If the conflict is intractable or destructive, abort safely:
   ```bash
   git rebase --abort
   ```
