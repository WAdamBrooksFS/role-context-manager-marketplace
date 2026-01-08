# Engineering Standards

<!-- LLM: Keep this lean for start-ups. Essential-only standards. As team grows, add more. Help enforce basics: code review, testing, git workflow. Avoid premature optimization or enterprise overhead. -->

**Status:** Living | **Update Frequency:** Quarterly
**Primary Roles:** Technical Co-founder, Founding Engineers
**Related Documents:** `/engineering/tech-stack.md`, `/engineering/contributing.md`

## Purpose

Essential coding and collaboration standards for the team. Keep it simple at your stage - you need enough structure to maintain quality without slowing down.

**Start-Up Reality:**
- Keep standards minimal and practical
- Focus on what prevents bugs and enables fast iteration
- Add complexity only as team grows

---

## Code Quality Standards

### General Principles
1. **Readability over cleverness** - Code is read 10x more than written
2. **Simple over complex** - Solve today's problem, not tomorrow's hypothetical
3. **Tested over perfect** - Ship with tests, iterate based on reality
4. **Consistent over personal preference** - Follow team style

### Code Review Requirements

**All code must be reviewed before merging to main:**
- **Minimum:** 1 approval from another engineer
- **For critical changes:** 2 approvals or Technical Co-founder approval
- **Self-review checklist before requesting review:**
  - [ ] Code works locally
  - [ ] Tests pass
  - [ ] No debugging code left in
  - [ ] Clear commit messages
  - [ ] PR description explains what and why

**Code Review Guidelines:**
- Review within 24 hours (prioritize unblocking teammates)
- Focus on logic, not style (use linters for style)
- Ask questions, don't demand changes
- Approve if it's good enough, not perfect

### Testing Standards

**Minimum Testing Requirements:**
- **Unit tests:** For business logic, utilities, algorithms
- **Integration tests:** For API endpoints, database interactions
- **E2E tests:** For critical user flows (sign-up, checkout, etc.)

**Coverage Goals:**
- Core features: 80%+ coverage
- New code: Tests required for PR approval
- Bug fixes: Add test that would have caught the bug

**What to Test:**
- Happy paths (main user flows)
- Edge cases (null, empty, invalid inputs)
- Error conditions (API failures, timeouts)

**What NOT to Test (at your stage):**
- Every single line (diminishing returns)
- Framework internals (trust the framework)
- UI pixel-perfect positioning (use E2E for flows, not aesthetics)

---

## Git Workflow

### Branch Strategy

**Main Branches:**
- `main` - Production code, always deployable
- `staging` (optional) - Pre-production testing

**Feature Branches:**
- Create from `main`
- Name format: `feature/short-description` or `fix/bug-description`
- Examples: `feature/add-search`, `fix/login-timeout`

**Branch Lifecycle:**
1. Create feature branch from `main`
2. Develop and commit regularly
3. Open PR when ready for review
4. Address review feedback
5. Merge to `main` (squash or merge commit)
6. Delete feature branch

### Commit Messages

**Format:**
```
<type>: <short summary>

<optional longer description>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code restructuring (no behavior change)
- `test`: Adding or updating tests
- `chore`: Build, dependencies, tooling

**Examples:**
- `feat: add user authentication`
- `fix: resolve login timeout issue`
- `docs: update API documentation`
- `refactor: simplify payment processing logic`

**Good Commits:**
- Clear what changed and why
- Small and focused (one logical change)
- Can be easily reverted if needed

**Bad Commits:**
- "fix stuff"
- "wip" (work in progress - squash these before merging)
- Giant commits changing 50 files

---

## Code Style

### Use Automated Formatting

**Don't argue about style - automate it:**
- **JavaScript/TypeScript:** Prettier + ESLint
- **Python:** Black + pylint
- **Go:** gofmt + golint
- **Other languages:** Use standard formatter for that language

**Configuration:**
- Set up in CI/CD to automatically check
- Run formatter on save in IDE
- Block PRs that don't pass linting

### Naming Conventions

**General:**
- Use clear, descriptive names
- Avoid abbreviations unless standard (id, url, api)
- Be consistent with casing for each language

**Examples:**
- Functions: `getUserById()`, `calculateTotal()`
- Variables: `userName`, `totalPrice`, `isActive`
- Constants: `MAX_RETRIES`, `API_BASE_URL`
- Classes: `UserService`, `PaymentProcessor`

---

## Architecture & Design

### Keep It Simple

**At your stage, prioritize:**
1. **Ship fast** over perfect architecture
2. **Solve today's problems** not hypothetical scale problems
3. **Monolith** over microservices (for now)
4. **Standard patterns** over custom frameworks

### When to Refactor

**Refactor when:**
- Code is confusing 3+ engineers
- Bug fixes require changing 10+ files
- Adding features takes 2x longer than it should
- Tech debt is blocking progress

**Don't refactor when:**
- "It could be more elegant" (ship first, refactor later)
- "We might need to scale this someday" (YAGNI)
- You're bored (ship features instead)

### API Design Principles

**RESTful APIs:**
- Use standard HTTP methods (GET, POST, PUT, DELETE)
- Plural nouns for resources (`/users`, `/products`)
- Clear, consistent response formats
- Proper status codes (200, 201, 400, 401, 404, 500)

**Error Handling:**
- Return meaningful error messages
- Include error codes for client-side handling
- Log errors with context (user ID, request ID, etc.)

---

## Security Basics

**Must-Do (Non-Negotiable):**
- [ ] No secrets in code (use environment variables)
- [ ] Hash passwords (use bcrypt, never plain text)
- [ ] Validate all user input (never trust client)
- [ ] Use HTTPS everywhere
- [ ] Keep dependencies updated (run `npm audit` or equivalent weekly)

**Should-Do (As Soon As Possible):**
- [ ] Implement rate limiting on APIs
- [ ] Add CORS configuration
- [ ] SQL injection prevention (use parameterized queries)
- [ ] XSS prevention (sanitize inputs, escape outputs)
- [ ] CSRF protection for state-changing operations

**Reference:** See `/operations/security-checklist.md` for details

---

## Performance Guidelines

**Measure Before Optimizing:**
- Don't optimize without profiling
- Focus on user-facing performance first
- Server costs are cheap, engineering time is expensive

**Basic Performance Practices:**
- Index database queries
- Cache expensive operations
- Lazy-load large resources
- Paginate large lists
- Use CDN for static assets

**When to Worry About Performance:**
- Page load > 3 seconds
- API response > 1 second
- Database queries > 100ms
- Users complaining about slowness

**When NOT to Worry:**
- Hypothetical scale ("what if we have 1M users?")
- Internal tools (optimize user-facing first)
- Background jobs (unless blocking users)

---

## Dependencies & Third-Party Code

### Dependency Management

**Adding Dependencies:**
- Prefer well-maintained, popular libraries
- Check last update date (avoid abandoned packages)
- Review license compatibility
- Consider bundle size impact (for frontend)

**Updating Dependencies:**
- Update regularly (weekly or bi-weekly)
- Test after updates
- Pin versions in production (avoid surprise breaks)

**Security:**
- Run security audits (npm audit, safety, etc.)
- Update vulnerable dependencies immediately
- Subscribe to security advisories for key packages

### When to Build vs Buy

**Buy (use existing library) when:**
- Standard functionality (auth, payments, emails)
- Security-critical (crypto, auth)
- Complex domain (date/time handling, internationalization)
- Well-maintained open source available

**Build when:**
- Core differentiation (your unique value)
- Simple problem (< 1 day to build)
- No good existing solution
- External dependency would be fragile

---

## Documentation

### Code Documentation

**What to Document:**
- **Functions:** What it does, parameters, return value (if not obvious)
- **Complex logic:** Why this approach (not what the code does)
- **APIs:** Endpoints, parameters, responses, examples
- **Setup:** How to run locally, env variables needed

**What NOT to Document:**
- Obvious code (don't write "this function adds two numbers")
- Implementation details that might change
- Anything better expressed in code

### Keep Documentation Close to Code

**Prefer:**
- Inline comments for complex logic
- README.md in each major directory
- API documentation (Swagger, OpenAPI)
- Docstrings/JSDoc for functions

**Avoid:**
- Separate wiki that gets outdated
- Long Word docs no one reads
- Documentation for documentation's sake

---

## Deployment & CI/CD

### Continuous Integration

**Every PR must:**
- Pass all tests
- Pass linter/formatter
- Build successfully

**CI Pipeline Should:**
- Run in < 10 minutes (faster is better)
- Fail fast (run fastest tests first)
- Provide clear error messages

### Deployment Process

**At your stage:**
- Deploy to staging first (if you have staging)
- Manual approval for production
- Deploy during low-traffic hours initially

**Deployment Checklist:**
- [ ] All tests pass
- [ ] Code reviewed and approved
- [ ] Database migrations run (if applicable)
- [ ] Environment variables updated
- [ ] Monitoring/alerts configured

**Rollback Plan:**
- Know how to rollback quickly
- Keep previous version accessible
- Test rollback process periodically

---

## Monitoring & Debugging

### Essential Monitoring

**Must Have:**
- Error tracking (Sentry, Bugsnag, etc.)
- Application logs (CloudWatch, Datadog, etc.)
- Uptime monitoring (Pingdom, UptimeRobot, etc.)

**Key Metrics to Track:**
- Error rate
- API response times
- Server CPU/memory usage
- Database query performance

### Debugging Practices

**When Debugging:**
- Reproduce the issue first
- Check logs and error tracking
- Use debugger, not print statements (mostly)
- Add tests after fixing bug

**Production Debugging:**
- Never debug directly in production
- Reproduce in staging/local first
- Use feature flags to isolate issues
- Have rollback plan ready

---

## Team Collaboration

### Communication

**Async First:**
- Document decisions in PRs, issues, or docs
- Minimize meetings
- Use written communication for non-urgent items

**Sync When Needed:**
- Complex problems need discussion
- Architectural decisions
- Blocked or urgent issues

### Knowledge Sharing

**At your stage:**
- Quick architecture decisions documented in code comments or ADRs
- Share learnings in team chat or standups
- Pair program on complex features
- Rotate code review partners

---

## Tools & Setup

### Required Tools

**Development:**
- IDE: [Your preferred IDE with standard setup]
- Git: Version control
- [Language-specific tools]
- Docker (if using containers)

**Collaboration:**
- GitHub/GitLab for code
- Slack/Discord for chat
- Linear/GitHub Issues for task tracking

**Monitoring:**
- Error tracking: [Sentry / Bugsnag / etc.]
- Logs: [CloudWatch / Datadog / etc.]
- Uptime: [Pingdom / UptimeRobot / etc.]

---

## Evolving These Standards

**Review Quarterly:**
- What's working?
- What's slowing us down?
- What should we add/remove?

**Add Standards When:**
- Same mistake happens 3+ times
- Team growth requires more coordination
- Specific pain point emerges

**Remove Standards When:**
- No one follows it anyway
- It's slowing down velocity without clear benefit
- It's no longer relevant

---

**Last Updated:** [Date]
**Next Review:** [Quarterly]
**Document Owner:** Technical Co-founder

<!-- LLM: When helping with engineering standards, keep it practical and minimal. Start-ups need just enough process to not break things. Add complexity only when pain is felt. If a standard isn't preventing real problems, it's probably premature. Focus on: code review, testing, git workflow, security basics. Everything else can wait. -->
