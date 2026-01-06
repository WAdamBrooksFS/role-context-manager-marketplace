# Engineering Standards

<!-- LLM: When reviewing code, RFCs, or technical designs, validate against these standards. Flag violations and suggest corrections. These standards balance consistency with team autonomy - enforce the "must" requirements strictly, treat "should" as strong guidance, and allow flexibility on "may" items. -->

**Status:** Living | **Update Frequency:** Quarterly
**Primary Roles:** CTO/VP Engineering, Engineering Managers, All Engineers
**Related Documents:** `/quality-standards.md`, `/infrastructure-standards.md`, `project-*/contributing.md`

## Purpose

This document defines company-wide engineering standards that apply across all systems, products, and projects. These standards ensure consistency, maintainability, quality, and security while allowing teams flexibility in implementation details.

---

## Code Standards

### Language-Specific Guidelines

**Supported Languages:**
- **Primary**: [Language 1], [Language 2]
- **Secondary**: [Language 3], [Language 4]
- **Deprecated**: [Old Language] (migration plan: [link])

**Language-Specific Style Guides:**
- [Language]: Follow [Style Guide Name] ([link])
  - **Must**: Run [linter/formatter] before commit
  - **Config**: Use company config at [path]

<!-- Example:
**Supported Languages:**
- **Primary**: Go, Python, TypeScript
- **Secondary**: Rust (infrastructure), Kotlin (Android)
- **Deprecated**: Ruby (migrating to Go by Q4 2024)

**Language-Specific Style Guides:**
- **Go**: Follow Effective Go + Google Go Style Guide
  - **Must**: Run `gofmt` and `golangci-lint` before commit
  - **Config**: `.golangci.yml` in repo root
- **Python**: Follow PEP 8 + Google Python Style Guide
  - **Must**: Run `black` (formatter) and `ruff` (linter)
  - **Config**: `pyproject.toml` in repo root
- **TypeScript**: Follow Airbnb TypeScript Style Guide
  - **Must**: Run `prettier` and `eslint`
  - **Config**: `.eslintrc.js` and `.prettierrc` in repo root
-->

### Code Review Requirements

**All code changes MUST:**
- Be reviewed by at least [N] engineer(s) before merge
- Pass all automated checks (linting, tests, security scans)
- Include tests for new functionality (see Quality Standards)
- Update documentation if behavior changes

**Code reviews SHOULD:**
- Happen within [N] business hours of submission
- Focus on correctness, design, maintainability (not style - automation handles that)
- Be respectful and constructive

**Review Checklist:**
- [ ] Code is correct and handles edge cases
- [ ] Tests cover new functionality and edge cases
- [ ] No security vulnerabilities introduced
- [ ] Performance implications considered
- [ ] Documentation updated (API docs, READMEs, etc.)
- [ ] Breaking changes are documented and migration path provided

### Naming Conventions

**General Principles:**
- **Must**: Names must be descriptive and unambiguous
- **Must**: Avoid abbreviations unless universally understood (HTTP, API, ID are OK; usr, msg are NOT)
- **Should**: Prefer longer, clear names over short, cryptic ones

**Variables:**
- `[language convention]` - [description]

**Functions/Methods:**
- `[language convention]` - [description]

**Classes/Types:**
- `[language convention]` - [description]

<!-- Example:
**Variables:**
- `camelCase` (TypeScript, Java) or `snake_case` (Python, Go): Descriptive nouns
- Good: `userAuthToken`, `totalOrderCount`
- Bad: `token`, `count`, `x`

**Functions/Methods:**
- `camelCase` (TypeScript, Java) or `snake_case` (Python, Go): Verb + noun
- Good: `calculateTotalPrice()`, `fetchUserProfile()`
- Bad: `calc()`, `get()`, `doStuff()`

**Classes/Types:**
- `PascalCase` (all languages): Noun describing the concept
- Good: `UserAccount`, `PaymentProcessor`
- Bad: `Manager`, `Helper`, `Util`
-->

### Documentation in Code

**All code MUST include:**
- File-level documentation explaining purpose (except trivial files)
- Function/method documentation for public APIs
- Inline comments for complex logic

**Documentation SHOULD:**
- Explain *why*, not *what* (code shows what, comments explain why)
- Be updated when code changes (stale comments are worse than no comments)
- Avoid stating the obvious

---

## Version Control

### Git Workflow

**Branching Strategy:** [Strategy name]

**Branch Naming:**
- `feature/[ticket-id]-[short-description]` - New features
- `bugfix/[ticket-id]-[short-description]` - Bug fixes
- `hotfix/[short-description]` - Production hotfixes
- `chore/[short-description]` - Non-functional changes

**Main Branches:**
- `main` - Production code, always deployable
- `develop` - Integration branch (if using GitFlow)

<!-- Example:
**Branching Strategy:** GitHub Flow (simplified)

**Main Branches:**
- `main` - Production code, always deployable
- Feature branches merge directly to `main` after review
- No long-lived branches except `main`
-->

### Commit Standards

**Commit Message Format:**
```
[type]([scope]): [short summary]

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring (no behavior change)
- `test`: Adding/updating tests
- `chore`: Tooling, dependencies, non-code changes
- `perf`: Performance improvements

**Examples:**
```
feat(auth): add OAuth2 support for GitHub login

Implements OAuth2 authentication flow for GitHub as login provider.
Includes token refresh logic and profile sync.

Closes #1234
```

```
fix(api): prevent race condition in user session cleanup

Added mutex lock around session deletion to prevent concurrent
access bug that caused null pointer exceptions.

Fixes #5678
```

### Pull Request Standards

**PR Title:** Same format as commit messages

**PR Description MUST include:**
- **What**: What changed
- **Why**: Why this change was needed
- **How**: How it was implemented (if not obvious)
- **Testing**: How it was tested
- **Screenshots**: For UI changes
- **Breaking Changes**: If any, with migration guide

**PR Template:** Use template at `.github/pull_request_template.md`

**PR Size:**
- **Should**: Keep PRs under [N] lines of code changes
- **Large PRs**: Break into smaller PRs when possible, or justify why it must be large

---

## Testing Standards

*See `/quality-standards.md` for comprehensive testing requirements*

**Minimum Requirements (enforced):**
- All new code MUST include automated tests
- Test coverage MUST NOT decrease (enforced by CI)
- All tests MUST pass before merge

---

## Security Standards

*See `/security-policy.md` for comprehensive security requirements*

**Code-Level Security MUST:**
- No secrets (API keys, passwords) in code
- Use parameterized queries (no SQL injection risk)
- Validate and sanitize all user input
- Use approved cryptography libraries (no custom crypto)
- Follow principle of least privilege (minimal permissions)

**Security Scanning:**
- **Must**: Run automated security scans on every PR
- **Must**: Fix all critical/high vulnerabilities before merge
- **Should**: Address medium vulnerabilities within 7 days

---

## Dependency Management

### Package Management

**Allowed Package Managers:**
- [Language]: [Package manager]

**Dependency Rules:**
- **Must**: Pin exact versions in production dependencies
- **Should**: Use version ranges for development dependencies
- **Must**: Review security advisories before adding new dependencies
- **Must**: Keep dependencies up to date (automated updates acceptable for patches)

<!-- Example:
**Allowed Package Managers:**
- Go: Go Modules
- Python: pip + pip-tools (or Poetry)
- TypeScript: npm or yarn (choose per project)

**Dependency Rules:**
- **Must**: Pin exact versions in `requirements.txt` / `package-lock.json`
- **Must**: Use Dependabot or Renovate for automated dependency updates
- **Must**: Review and approve all dependency updates (don't auto-merge blindly)
-->

### Open Source Usage

**Before adding a dependency, verify:**
- [ ] License is compatible with our product ([acceptable licenses list])
- [ ] Package is actively maintained (commit activity in last 6 months)
- [ ] Package has reasonable security track record (check CVEs)
- [ ] No better-maintained alternatives exist

**Approved Licenses:**
- ✅ MIT, Apache 2.0, BSD-3-Clause
- ⚠️ LGPL (requires legal review)
- ❌ GPL, AGPL (not allowed for production code)

---

## API Design

### REST API Standards

**Must follow:**
- RESTful resource naming: `/users`, `/orders/{id}`
- HTTP verbs correctly: GET (read), POST (create), PUT (replace), PATCH (update), DELETE (delete)
- Standard HTTP status codes ([link to reference])

**URL Structure:**
- `[protocol]://[domain]/[version]/[resource]/[id]`
- Example: `https://api.company.com/v1/users/12345`

**Versioning:**
- **Must**: Version all public APIs (v1, v2, etc.)
- **Must**: Support previous version for at least [N] months after deprecation announcement

### GraphQL Standards

*If applicable*

**Schema Design:**
- [Naming conventions]
- [Query/mutation patterns]
- [Error handling]

### API Documentation

**All APIs MUST:**
- Be documented with OpenAPI/Swagger (REST) or GraphQL schema
- Include request/response examples
- Document error codes and meanings
- Provide authentication requirements

---

## Performance Standards

### Response Time Targets

**API Endpoints:**
- p50: < [X]ms
- p95: < [Y]ms
- p99: < [Z]ms

**Page Load (Web):**
- First Contentful Paint: < [X]s
- Time to Interactive: < [Y]s

**Database Queries:**
- Individual queries: < [X]ms
- N+1 queries: Not allowed (use eager loading)

### Monitoring Requirements

**All production services MUST:**
- Emit metrics (request rate, latency, error rate)
- Emit structured logs (JSON format)
- Implement health check endpoints
- Support distributed tracing

---

## Infrastructure as Code

**All infrastructure MUST:**
- Be defined in code (Terraform, CloudFormation, Pulumi, etc.)
- Be version controlled
- Be peer reviewed before applying
- Support multiple environments (dev, staging, production)

**Infrastructure Changes:**
- **Must**: Test in non-production environment first
- **Must**: Have rollback plan
- **Should**: Use blue-green or canary deployments for production

*See `/infrastructure-standards.md` for details*

---

## Exceptions and Waivers

### Requesting an Exception

Sometimes standards need exceptions. To request a waiver:

1. Document why the standard doesn't apply
2. Explain the alternative approach
3. Assess risks of not following the standard
4. Get approval from [role, e.g., Staff Engineer + Engineering Manager]

**Example Valid Exceptions:**
- Using non-standard library because standard option doesn't support required feature
- Skipping test coverage requirement for generated code
- Emergency hotfix that bypasses normal review process (must be reviewed retrospectively)

### Recording Exceptions

**All exceptions MUST:**
- Be documented in Architecture Decision Record (ADR)
- Include expiration date or re-evaluation trigger
- Be reviewed in [quarterly engineering review]

---

## Enforcement

### Automated Enforcement

**CI/CD pipeline MUST:**
- Run linters and fail build on violations
- Run tests and fail on any failures
- Run security scanners and fail on critical issues
- Enforce code coverage thresholds

### Manual Enforcement

**Code reviewers MUST:**
- Block PRs that violate standards
- Escalate repeated violations to engineering management

**Engineering managers SHOULD:**
- Address pattern of violations in 1:1s
- Include standards adherence in performance reviews

---

## Updates to Standards

**Proposing Changes:**
1. Create RFC (Request for Comments) document
2. Get input from engineering team
3. CTO/VP Engineering approves
4. Communicate changes in all-hands
5. Update this document
6. Update tooling/automation to match

**Backward Compatibility:**
- New standards should not require immediate rewrite of existing code
- Provide migration period and tooling support
- "Grandfathered" code must be updated during refactors

---

<!-- LLM: When reviewing code or technical designs, strictly enforce "MUST" requirements - these are non-negotiable. For "SHOULD" requirements, flag violations but suggest rather than block. For "MAY" items, these are optional best practices. If you see a valid reason for an exception, guide the user through the exception process rather than blocking them. -->
