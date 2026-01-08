# Contributing Guide

<!--LLM: Simple guide for engineers to contribute code. Focus on workflow, not philosophy.-->

**Status:** Living | **Update Frequency:** As needed
**Primary Roles:** All Engineers
**Related Documents:** `/engineering/engineering-standards.md`, `/engineering/development-setup.md`

## Quick Start

1. **Set up your environment:** See `/engineering/development-setup.md`
2. **Pick a task:** Check Linear/GitHub issues or ask in Slack
3. **Create a branch:** `git checkout -b feature/your-feature-name`
4. **Code and test:** Write code, add tests, run locally
5. **Submit PR:** Push branch, create PR with description
6. **Get review:** Address feedback, iterate
7. **Merge:** Once approved, merge to main

## Pull Request Process

### Before Creating PR
- [ ] Code works locally
- [ ] Tests pass (`npm test` or equivalent)
- [ ] Linter passes (`npm run lint`)
- [ ] No debugging code/console.logs left in
- [ ] Commit messages are clear

### PR Description Template
```markdown
## What
[What does this PR do in 1-2 sentences]

## Why
[Why are we making this change]

## How to Test
1. [Step 1]
2. [Step 2]
3. [Expected result]

## Screenshots (if UI change)
[Add screenshots if relevant]
```

### Code Review
- PRs reviewed within 24 hours
- Address feedback promptly
- Approve when good enough, not perfect

## Git Workflow

**Branch naming:**
- `feature/description` - New feature
- `fix/description` - Bug fix
- `refactor/description` - Code improvement

**Commit format:**
```
type: short description

Optional longer description
```

**Types:** feat, fix, docs, refactor, test, chore

## Testing Requirements

**Must have:**
- Unit tests for business logic
- Tests pass before merging

**Should have:**
- Integration tests for APIs
- E2E tests for critical flows

## Getting Help

**Stuck?** Ask in Slack #engineering channel
**Bug?** Check error logs first, then ask
**Not sure?** Ask before spending hours

---

**Last Updated:** [Date]
**Document Owner:** Technical Co-founder
