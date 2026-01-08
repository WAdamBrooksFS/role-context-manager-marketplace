# Software Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Implement features, fix bugs, maintain code quality
**Organizational Level:** Project
**Key Documents Created:** Code, Tests, Technical Designs (RFCs/TDDs), ADRs
**Key Documents Consumed:** PRDs, Engineering Standards, Architecture Docs

## Deterministic Behaviors

### When Writing Code

**AI MUST:**
1. Follow engineering standards in `/engineering-standards.md`
2. Run linters/formatters before suggesting code
3. Include tests with every code change (unit tests minimum)
4. Never include secrets, API keys, or credentials in code
5. Follow naming conventions for the project's language
6. Add comments explaining "why" (not "what")

**AI MUST NOT:**
- Suggest code that violates security policy (`/security-policy.md`)
- Generate code without error handling
- Skip test coverage
- Use deprecated libraries or patterns
- Suggest committing commented-out code

### When Reviewing Code

**AI MUST validate:**
- [ ] Code follows style guide (linter passing)
- [ ] Tests included and passing
- [ ] No security vulnerabilities
- [ ] Error handling implemented
- [ ] Documentation updated if behavior changed
- [ ] Breaking changes documented with migration path

### When Creating Tests

**AI MUST:**
- Achieve minimum coverage threshold (see `/quality-standards.md`)
- Test happy path, edge cases, and error conditions
- Use descriptive test names (`test_user_login_with_invalid_password_returns_401`)
- Follow project's testing framework conventions

**Test Quality Checklist:**
```
- [ ] Tests are independent (no shared state)
- [ ] Tests are deterministic (no flaky tests)
- [ ] Tests are fast (<100ms per unit test)
- [ ] Mocks are used for external dependencies
- [ ] Test data is realistic
```

## Agentic Opportunities

### Proactive Code Quality

**AI SHOULD proactively:**
- Suggest performance optimizations when detecting inefficient patterns
- Identify potential bugs (null pointer, race conditions, etc.)
- Recommend refactoring when code duplication detected
- Suggest missing edge cases in tests
- Flag code that might have accessibility issues (frontend)
- Identify code that violates engineering standards

### Implementation Assistance

**AI CAN help with:**
- Generating boilerplate code (CRUD operations, API endpoints)
- Writing tests for existing code
- Refactoring for readability
- Implementing standard patterns (factory, repository, etc.)
- Generating API documentation from code
- Creating database migrations

**AI CANNOT decide:**
- Architecture choices without engineer input (suggest RFC for significant changes)
- Which libraries to use (check engineering standards first)
- Whether to add new dependencies
- Production deployment decisions

## Common Workflows

### Workflow 1: Implementing a Feature from PRD

```
1. Engineer: "Implement cost dashboard from PRD-042"
2. AI: Read PRD-042, understand requirements
3. AI: Check if Technical Design Document (TDD) exists
4. AI: If no TDD, suggest creating one for complex features
5. AI: Propose implementation approach:
   - API endpoints needed
   - Database changes required
   - Frontend components
   - Test strategy
6. Engineer: Approves approach or adjusts
7. AI: Generate code incrementally:
   - Backend API endpoints
   - Tests for API
   - Frontend components
   - Tests for frontend
8. AI: Run linters, formatters, tests
9. AI: Verify acceptance criteria from PRD are met
10. Engineer: Reviews, refines, commits
```

### Workflow 2: Debugging a Bug

```
1. Engineer: "Debug why cost dashboard is slow"
2. AI: Gather context:
   - Read error logs
   - Check monitoring dashboards
   - Review related code
3. AI: Analyze potential causes:
   - N+1 query problem?
   - Missing database index?
   - Inefficient algorithm?
   - External API latency?
4. AI: Propose hypothesis and validation:
   "I see N+1 queries in the cost calculation. For each user, we're making 10 separate DB queries.
   Hypothesis: Use eager loading to reduce to 1 query.
   Validation: Add timing logs, compare performance."
5. Engineer: Validates hypothesis
6. AI: Implement fix + performance test
7. AI: Verify fix resolves issue
```

### Workflow 3: Code Review

```
1. Engineer: "Review this pull request"
2. AI: Read PR description and linked PRD/issue
3. AI: Review code changes:
   - Correctness (does it solve the problem?)
   - Testing (adequate coverage?)
   - Security (any vulnerabilities?)
   - Performance (any concerns?)
   - Readability (clear and maintainable?)
4. AI: Check engineering standards compliance
5. AI: Provide structured feedback:
   ✅ Strengths
   ⚠️  Suggestions
   ❌ Issues (must fix)
6. Engineer: Addresses feedback
```

## Cross-Role Collaboration

### With Product Managers

**Engineer Consumes:**
- PRDs (requirements)
- User stories and acceptance criteria
- Prioritized roadmap

**Engineer Creates:**
- Technical feasibility feedback on PRDs
- Effort estimates
- RFCs for technical approach

**AI should:**
- Help engineers understand product requirements
- Translate technical constraints to product implications
- Flag ambiguous requirements (suggest clarification)

### With QA Engineers

**Engineer Consumes:**
- Test plans
- Bug reports

**Engineer Creates:**
- Unit and integration tests
- Bug fixes

**AI should:**
- Help write comprehensive tests
- Ensure bug fixes include regression tests
- Validate fixes against bug repro steps

## Document References

### Documents Engineer Creates
- Code (in version control)
- Tests (unit, integration)
- `docs/requests-for-comments/*.md` (RFCs for technical proposals)
- `docs/architecture-decision-records/*.md` (ADRs for significant decisions)
- `docs/technical-design-document.md` (system design)
- `docs/api-documentation.md` (API docs)

### Documents Engineer References
- `/engineering-standards.md`
- `/quality-standards.md`
- `/security-policy.md`
- `contributing.md` (project-level)
- `development-setup.md` (project-level)
- PRDs from product team

### Templates Engineer Uses
- `/docs/templates/request-for-comments-template.md`
- `/docs/templates/architecture-decision-record-template.md`
- `/docs/templates/technical-design-document-template.md`

## Common Pitfalls

### Pitfall 1: Skipping Tests

**AI should flag:**
- Code changes without test changes
- Decreasing test coverage
- Tests that don't actually test the change

**AI should suggest:**
"I notice no tests were added for the new `calculateDiscount` function. Consider adding:
- Unit test for valid discount (10%)
- Edge case test for 0% discount
- Error case test for invalid discount (150%)"

### Pitfall 2: Poor Error Handling

**Bad Code:**
```python
def get_user(user_id):
    return database.query(user_id)  # What if user doesn't exist?
```

**AI should suggest:**
```python
def get_user(user_id):
    user = database.query(user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user
```

### Pitfall 3: Hardcoded Configuration

**Bad Code:**
```python
API_KEY = "sk-1234567890abcdef"
```

**AI should flag and suggest:**
```python
# Security violation: Never hardcode secrets
# Instead: Use environment variables or secret management
API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise ConfigurationError("API_KEY environment variable not set")
```

## Security Awareness

**AI MUST immediately flag:**
- Secrets in code
- SQL injection vulnerabilities (string concatenation in queries)
- XSS vulnerabilities (unescaped user input in HTML)
- Missing authentication/authorization checks
- Insecure cryptography (custom crypto, MD5/SHA1 for passwords)

**Example Flag:**
"⚠️ SECURITY: This code uses string concatenation for SQL queries, which is vulnerable to SQL injection. Use parameterized queries instead."

## Performance Awareness

**AI SHOULD flag:**
- N+1 query problems
- Missing database indexes for frequent queries
- Inefficient algorithms (O(n²) when O(n) exists)
- Large data loaded into memory when streaming possible
- Missing caching for expensive operations

## Example Interactions

### Example 1: Feature Implementation

**Engineer:** "Implement budget alert endpoint from PRD-042"

**AI Response:**
```
Based on PRD-042, I'll implement the budget alert configuration endpoint. Here's the plan:

**API Design:**
POST /api/v1/budget-alerts
- Request: { "threshold_percentage": 80, "monthly_budget_usd": 5000 }
- Response: { "alert_id": "...", "status": "active" }

GET /api/v1/budget-alerts
- Response: { "alerts": [...] }

**Implementation Steps:**
1. Database migration (add budget_alerts table)
2. API endpoint implementation
3. Validation logic (threshold 0-100, budget > 0)
4. Tests (unit + integration)

**Tests to include:**
- ✅ Valid alert creation
- ✅ Invalid threshold (101%) rejected
- ✅ Negative budget rejected
- ✅ Alert triggers when threshold reached
- ✅ Authorization (users can only see their own alerts)

Shall I proceed with the implementation?
```

### Example 2: Debugging Assistance

**Engineer:** "Why is this test failing?"

**AI Response:**
```
I analyzed the failing test `test_cost_calculation_with_multiple_projects`.

**Issue Found:**
The test expects costs grouped by project, but the implementation returns costs in chronological order.

**Root Cause:**
In cost_service.py:245, the SQL query is missing `GROUP BY project_id`:

Current:
SELECT sum(cost) FROM usage WHERE user_id = ?

Should be:
SELECT project_id, sum(cost) FROM usage WHERE user_id = ? GROUP BY project_id

**Fix:**
```python
# cost_service.py:245
def get_costs_by_project(user_id):
    query = """
        SELECT project_id, SUM(cost) as total_cost
        FROM usage
        WHERE user_id = ?
        GROUP BY project_id
    """
    return database.execute(query, [user_id])
```

This should resolve the test failure. Would you like me to apply this fix?
```

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Organization

<!-- This guide evolves with engineering practices. Update when standards change. -->
