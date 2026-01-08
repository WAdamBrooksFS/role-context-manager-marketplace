# Contributing to [Project Name]

<!-- LLM: This is the day-to-day guide for engineers. Help them follow these practices. Enforce coding standards, ensure tests are included, validate commit messages. This is where engineering standards meet daily work. -->

**Last Updated:** 2024-03-20
**Maintainers:** [Engineering Team Name]

## Quick Start

```bash
# Clone and setup
git clone [repo-url]
cd project-a-template
./scripts/setup.sh  # See development-setup.md for details

# Run tests
npm test

# Start local development
npm run dev
```

See `development-setup.md` for full setup instructions.

---

## Development Workflow

### 1. Create a Branch

Follow naming convention from `/engineering-standards.md`:
```bash
git checkout -b feature/PRD-042-cost-dashboard
git checkout -b bugfix/login-redirect-issue
git checkout -b chore/update-dependencies
```

### 2. Make Changes

**Required:**
- Follow code style (auto-formatted by `npm run format`)
- Write tests for all changes
- Update documentation if behavior changes
- Keep commits small and focused

### 3. Write Tests

**Minimum requirements** (from `/quality-standards.md`):
- Unit tests for all new functions/methods
- Integration tests for API endpoints
- Achieve 80%+ line coverage

```bash
# Run tests
npm test

# Check coverage
npm run test:coverage

# Should see: Coverage > 80%
```

### 4. Commit Changes

Follow commit message format from `/engineering-standards.md`:

```bash
git commit -m "feat(dashboard): add real-time cost display

Implements cost dashboard showing today/week/month costs.
Includes API integration and auto-refresh every 5 minutes.

Closes PRD-042"
```

### 5. Create Pull Request

**PR must include:**
- Link to PRD or issue
- Description of changes (what, why, how)
- Screenshots for UI changes
- Test results

**PR template:**
```markdown
## What
[What changed]

## Why
[Why this change was needed - link to PRD/issue]

## How
[Implementation approach]

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing complete

## Checklist
- [ ] Code follows style guide
- [ ] Tests included and passing
- [ ] Documentation updated
- [ ] No security vulnerabilities
```

### 6. Code Review

**Requirements:**
- At least 1 approval from team member
- All CI checks passing
- No unresolved comments

**Reviewers check:**
- Code correctness
- Test coverage
- Security implications
- Performance considerations
- Documentation

### 7. Merge and Deploy

```bash
# Squash and merge (preferred)
gh pr merge --squash

# Auto-deploys to staging on merge to main
# Deploy to production after QA approval
```

---

## Code Standards

**Follow company standards:**
- `/engineering-standards.md` - Company-wide standards
- `/quality-standards.md` - Testing requirements
- `/security-policy.md` - Security requirements

**Project-specific conventions:**
- Frontend: React + TypeScript, functional components
- Backend: Node.js + Express, RESTful APIs
- Database: PostgreSQL, Prisma ORM
- Tests: Jest (unit), Playwright (E2E)

---

## Testing

### Running Tests

```bash
# All tests
npm test

# Unit tests only
npm run test:unit

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e

# Watch mode (for development)
npm run test:watch
```

### Writing Tests

**Unit Test Example:**
```typescript
import { calculateDiscount } from './pricing';

describe('calculateDiscount', () => {
  it('calculates 20% discount correctly', () => {
    expect(calculateDiscount(100, 20)).toBe(20);
  });

  it('handles 0% discount', () => {
    expect(calculateDiscount(100, 0)).toBe(0);
  });

  it('throws error for invalid discount', () => {
    expect(() => calculateDiscount(100, 150)).toThrow('Invalid discount');
  });
});
```

---

## Documentation

**When to update docs:**
- API changes: Update `docs/api-documentation.md`
- Architecture changes: Create ADR in `docs/architecture-decision-records/`
- New features: Update this file or relevant docs

**AI can help:**
- Generate API docs from code comments
- Draft ADRs from technical decisions
- Update docs when code changes

---

## Getting Help

**Resources:**
- Team Slack: #engineering-team-a
- Engineering Manager: [Name]
- Documentation: See `docs/` directory
- Company Standards: See `/` (root) for company-wide docs

**For AI assistance:**
- Code implementation
- Test writing
- Documentation generation
- Debugging help

---

<!-- LLM: Help engineers follow this workflow. Enforce standards automatically. Suggest tests when missing. Guide through PR process. -->
