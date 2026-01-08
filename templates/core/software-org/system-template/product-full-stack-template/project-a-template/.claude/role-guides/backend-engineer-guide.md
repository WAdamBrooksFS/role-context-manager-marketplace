# Backend Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build and maintain backend services and APIs
**Organizational Level:** Project
**Key Documents Created:** Backend code, API documentation, database schemas
**Key Documents Consumed:** PRDs, technical designs, engineering standards

## Deterministic Behaviors

### When Writing Backend Code

**AI MUST:**
- Follow engineering standards from `/engineering-standards.md`
- Include unit and integration tests (80%+ coverage)
- Never hardcode secrets, API keys, credentials (use environment variables)
- Implement proper error handling and logging
- Follow API design standards (REST/GraphQL conventions)
- Ensure database queries are optimized (indexes, no N+1 queries)
- Handle edge cases (null values, empty lists, invalid input)
- Include security controls (authentication, authorization, input validation)

**Validation Checklist:**
- [ ] Code follows engineering standards (linting passes)
- [ ] Unit tests for business logic
- [ ] Integration tests for API endpoints
- [ ] No secrets in code (environment variables used)
- [ ] Input validation (prevent injection attacks)
- [ ] Authentication and authorization implemented
- [ ] Error handling with appropriate status codes
- [ ] Logging for debugging and monitoring
- [ ] Database migrations included
- [ ] API documentation updated

### When Designing APIs

**AI MUST:**
- Follow REST or GraphQL best practices
- Use appropriate HTTP methods and status codes
- Include request/response examples
- Document error responses
- Specify authentication requirements
- Include rate limiting considerations
- Version APIs (URL versioning or headers)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest performance optimizations (caching, query optimization)
- Recommend security improvements (input validation, rate limiting)
- Flag potential SQL injection or XSS vulnerabilities
- Identify N+1 query problems
- Propose better error handling
- Highlight missing test coverage
- Suggest API design improvements

### Backend Development Support

**AI CAN help with:**
- API endpoint implementation
- Database query writing and optimization
- Test writing (unit, integration, API tests)
- Security vulnerability identification
- Performance profiling and optimization
- Error handling and logging
- API documentation generation
- Database schema design

**AI CANNOT:**
- Skip security requirements
- Commit code without tests
- Ignore performance issues
- Deploy without code review

## Common Workflows

### Workflow 1: Implement New API Endpoint

```
1. Backend Engineer: "Implement POST /api/users endpoint from PRD-123"
2. AI: Read PRD requirements
3. AI: Generate implementation:
   - Route handler
   - Input validation (email format, password strength)
   - Business logic (create user, hash password)
   - Database interaction
   - Error handling
   - Response formatting
4. AI: Generate tests:
   - Unit tests for validation logic
   - Integration tests for endpoint
   - Edge cases (duplicate email, invalid input)
5. AI: Update API documentation
6. Backend Engineer: Reviews, refines, submits PR
```

### Workflow 2: Optimize Slow Database Query

```
1. Backend Engineer: "Query taking 5 seconds, optimize"
2. AI: Analyze query execution plan
3. AI: Identify issues:
   - Missing index on frequently filtered column
   - N+1 query problem (looping queries)
   - Selecting unnecessary columns
4. AI: Propose fixes:
   - Add index on user_id column
   - Use JOIN instead of separate queries
   - Select only needed columns
5. AI: Estimate improvement: 5s → 50ms
6. Backend Engineer: Implements optimization
```

### Workflow 3: Security Vulnerability Remediation

```
1. Backend Engineer: "Fix SQL injection vulnerability in search endpoint"
2. AI: Analyze vulnerable code:
   - String concatenation in SQL query
3. AI: Generate secure fix:
   - Use parameterized queries
   - Add input validation
   - Implement rate limiting
4. AI: Add security tests:
   - Test SQL injection attempts
   - Test input validation
5. Backend Engineer: Reviews and applies fix
```

## Document References

### Documents Backend Engineer Creates
- `project-*/src/` (code)
- `project-*/docs/api-documentation.md`
- `project-*/tests/` (tests)
- `project-*/migrations/` (database migrations)

### Documents Backend Engineer References
- `/engineering-standards.md`
- `/quality-standards.md`
- `/security-policy.md`
- `product-*/docs/product-requirements-documents/*.md`
- `project-*/docs/technical-design-document.md`

## Common Pitfalls

### Pitfall 1: Hardcoded Secrets
**Bad:** `const API_KEY = "sk_live_abc123"` in code
**Good:** `const API_KEY = process.env.API_KEY`
**AI should flag:** "API key hardcoded. Use environment variable."

### Pitfall 2: Missing Input Validation
**Bad:** Trusting user input without validation
**Good:** Validate all input (type, format, range, length)
**AI should flag:** "Email not validated. Add email format validation."

### Pitfall 3: N+1 Query Problem
**Bad:** Looping to fetch related records (100 queries)
**Good:** Single JOIN query or eager loading
**AI should flag:** "N+1 query detected. Use JOIN or include() for better performance."

### Pitfall 4: Generic Error Messages
**Bad:** Returning database errors to users
**Good:** User-friendly errors, detailed logs for debugging
**AI should flag:** "Database error exposed to user. Return generic message, log details."

## Success Metrics for AI Collaboration

- Code follows engineering standards (100%)
- Test coverage meets standards (80%+)
- Zero security vulnerabilities in production
- API performance meets SLAs (P95 < 200ms)
- No secrets committed to code
- Database queries optimized (proper indexes)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Team
