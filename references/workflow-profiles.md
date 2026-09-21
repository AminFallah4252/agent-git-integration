# Workflow Profiles & Commit Standards

This guide covers branching models, commit formatting standards, and PR/MR templates configurable in `config.json`.

---

## 1. Branching Strategies

### Strategy A: Trunk-Based Development (Default & Recommended)
- **Concept**: Developers work in short-lived feature branches (< 1-2 days) that merge rapidly into `main`.
- **Branch Naming**:
  - `feat/<short-name>`: New features (`feat/jwt-auth`)
  - `fix/<short-name>`: Bug fixes (`fix/null-pointer-exception`)
  - `refactor/<short-name>`: Code refactoring without behavior change
  - `chore/<short-name>`: Tooling, dependencies, maintenance

### Strategy B: Git-Flow
- **Concept**: Structured releases with parallel long-lived branches.
  - `main`: Production-ready code only.
  - `develop`: Ongoing integration branch.
  - `feature/<name>`: Branched from `develop`, merged back to `develop`.
  - `release/<vX.X.X>`: Stabilization branch branched from `develop`, merged to `main` and `develop`.
  - `hotfix/<name>`: Critical production fix branched from `main`, merged to both `main` and `develop`.

---

## 2. Commit Conventions

### Conventional Commits 1.0.0
Format:
```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

#### Types:
- **`feat`**: A new feature for the user.
- **`fix`**: A bug fix.
- **`docs`**: Documentation only changes.
- **`style`**: Changes that do not affect code logic (formatting, missing semi-colons).
- **`refactor`**: Code change that neither fixes a bug nor adds a feature.
- **`perf`**: A code change that improves performance.
- **`test`**: Adding missing tests or correcting existing tests.
- **`build`**: Changes that affect the build system or external dependencies (npm, pip).
- **`ci`**: Changes to CI configuration files and scripts (GitHub Actions, GitLab CI).
- **`chore`**: Maintenance tasks, housekeeping, repo hygiene.

#### Examples:
```
feat(auth): implement OAuth2 Google provider flow
fix(parser): prevent index out of bounds on empty input
docs(readme): update installation instructions for Docker
refactor(database): decouple connection pool from handler
```

---

## 3. Pull Request & Merge Request Template

When generating PR or MR descriptions, use this structured markdown:

```markdown
## 📝 Summary
- Brief bullet-point summary of what this PR introduces and why.

## 🛠️ Changes Made
- Specific components, files, or endpoints touched.

## 🧪 Verification & Testing
- [x] Unit tests pass
- [x] Manual testing performed
- Detailed test steps and validation results.

## 🔗 Related Issues
- Closes #<issue_number>
```
