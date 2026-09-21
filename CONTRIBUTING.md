# Contributing to Agent Git Integration

Thank you for helping improve multi-provider Git automation for AI coding agents!

## How You Can Contribute

1. **New Hosting Providers**: Add integration modules for AWS CodeCommit, Azure DevOps Repos, Sourcehut, or OneDev.
2. **Workflow Strategies**: Submit workflow definitions or PR/MR automation templates for your team's preferred methodology.
3. **Security Refinements**: Propose additional pre-commit checks or credential resolution enhancements.

## Guidelines

- Keep all script interactions non-destructive and zero-leak (never output tokens).
- Maintain compatibility across both PowerShell and Bash.
- Document any new provider in `references/<provider>-operations.md` and link it in `SKILL.md` and `README.md`.
