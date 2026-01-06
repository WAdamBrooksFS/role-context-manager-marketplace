# Quality Standards

<!-- LLM: When reviewing code or test plans, validate against these quality standards. Ensure test coverage meets minimum thresholds, test types are appropriate for the change, and quality gates are respected. Help developers write better tests by suggesting missing test cases. -->

**Status:** Living | **Update Frequency:** Semi-annually
**Primary Roles:** Director of QA, QA Managers, All Engineers, SDETs, QA Engineers
**Related Documents:** `/engineering-standards.md`, `product-*/docs/test-strategy.md`, `project-*/docs/test-plan.md`

## Purpose

This document defines company-wide quality standards that ensure we ship reliable, maintainable, secure software. Quality is everyone's responsibility - these standards apply to all engineers, not just QA teams.

---

## Quality Philosophy

###Our Quality Principles

1. **Quality is Built In, Not Tested In**: Prevention over detection
2. **Automate Everything**: Manual testing is slow, expensive, and error-prone
3. **Shift Left**: Find issues earlier in development lifecycle
4. **Fast Feedback**: Tests should run in minutes, not hours
5. **Own Your Quality**: Engineers own quality of their code

---

## Testing Requirements by Level

### Unit Tests

**Definition:** Tests that verify a single unit (function, method, class) in isolation

**Requirements:**
- **Must**: Every new function/method must have unit tests
- **Must**: Achieve minimum [X]% line coverage for new code
- **Should**: Achieve [Y]% branch coverage
- **Must**: Run in < [N] seconds total

**What to Test:**
- Happy path (expected inputs → expected outputs)
- Edge cases (boundary conditions, empty inputs, max values)
- Error conditions (invalid inputs, exception handling)
- Business logic (calculations, transformations, validations)

**Example (Good Unit Test):**
```python
# Example in Python
def test_calculate_discount_percentage():
    # Happy path
    assert calculate_discount(100, 20) == 20.0

    # Edge cases
    assert calculate_discount(100, 0) == 0.0
    assert calculate_discount(0, 50) == 0.0

    # Error conditions
    with pytest.raises(ValueError):
        calculate_discount(100, -10)  # Negative discount
    with pytest.raises(ValueError):
        calculate_discount(100, 150)  # Discount > 100%
```

### Integration Tests

**Definition:** Tests that verify multiple components work together correctly

**Requirements:**
- **Must**: Test all critical integration points (API → database, service → service)
- **Should**: Cover authentication, authorization, data persistence
- **Must**: Use test database (not production data)
- **Should**: Run in < [N] minutes total

**What to Test:**
- API endpoints (request → response)
- Database operations (CRUD + transactions)
- External service integrations (with mocks or test environments)
- Message queues, event streams

**Example Scenarios:**
- User registration flow: API endpoint → database insert → email service
- Payment processing: API → payment gateway → database update → webhook
- Data pipeline: Ingest → transform → store → analytics query

### End-to-End (E2E) Tests

**Definition:** Tests that verify complete user workflows through the entire system

**Requirements:**
- **Must**: Cover critical business flows (user signup, checkout, core feature usage)
- **Should**: Run against staging environment before production deploy
- **May**: Run subset in CI, full suite nightly
- **Should**: Run in < [N] minutes for smoke tests, < [X] hours for full suite

**What to Test:**
- Critical user journeys (signup → login → use feature → logout)
- Cross-browser compatibility (Chrome, Firefox, Safari, Edge)
- Mobile responsiveness (if applicable)
- Performance under realistic load

**Tooling:**
- Web: [Playwright, Selenium, Cypress]
- Mobile: [Appium, XCUITest, Espresso]
- API: [Postman, RestAssured, Supertest]

### Performance Tests

**Definition:** Tests that verify system performance under load

**Requirements:**
- **Must**: Run performance tests before major releases
- **Must**: Test against production-like environment
- **Should**: Run regularly (weekly or nightly)

**Test Types:**
- **Load Testing**: Expected load (e.g., 1000 concurrent users)
- **Stress Testing**: Breaking point (increase load until failure)
- **Spike Testing**: Sudden load increase (traffic spike)
- **Soak Testing**: Sustained load (memory leaks, resource exhaustion)

**Success Criteria:**
- Response times meet targets (see `/engineering-standards.md#performance-standards`)
- No memory leaks over [N] hours
- Graceful degradation under overload (errors, not crashes)

### Security Tests

**Definition:** Tests that verify security controls and identify vulnerabilities

**Requirements:**
- **Must**: Run automated security scans on every PR
- **Must**: Perform penetration testing before major releases
- **Should**: Run dependency vulnerability scans daily

**Test Types:**
- **SAST** (Static Application Security Testing): Code analysis for vulnerabilities
- **DAST** (Dynamic Application Security Testing): Runtime vulnerability testing
- **Dependency Scanning**: Known vulnerabilities in third-party libraries
- **Penetration Testing**: Manual security testing by experts (quarterly or before major launches)

**Common Checks:**
- SQL injection, XSS, CSRF
- Authentication/authorization bypass
- Secrets in code or logs
- Insecure dependencies

---

## Test Coverage Requirements

### Coverage Thresholds

**Minimum Coverage (enforced by CI):**
- **Unit Test Coverage**: [X]% line coverage for new code
- **Critical Path Coverage**: 100% for payment, auth, data processing logic
- **Overall Coverage**: Target [Y]%, never decrease coverage in PRs

<!-- Example:
**Minimum Coverage (enforced by CI):**
- **Unit Test Coverage**: 80% line coverage for new code
- **Critical Path Coverage**: 100% for payment, auth, data processing logic
- **Overall Coverage**: Target 75%, never decrease coverage in PRs
-->

### Coverage Exceptions

**Acceptable Reasons to Skip Coverage:**
- Generated code (protobuf, ORM models)
- Third-party code we don't control
- Deprecated code being phased out (document in ADR)

**Process for Exceptions:**
1. Add comment explaining why coverage isn't needed
2. Get approval in code review
3. Document in test plan

---

## Quality Gates

### Pre-Merge Gates (CI/CD)

**All PRs MUST pass:**
- ✅ All unit tests pass
- ✅ All integration tests pass
- ✅ Code coverage meets threshold
- ✅ No linter errors
- ✅ Security scan passes (no critical/high issues)
- ✅ No merge conflicts
- ✅ At least [N] approving reviews

**If any gate fails:**
- PR cannot be merged
- Engineer must fix the issue
- No "merge anyway" exceptions (except documented emergency hotfixes)

### Pre-Deploy Gates (Staging)

**Before deploying to staging:**
- ✅ All CI checks pass
- ✅ E2E smoke tests pass
- ✅ Manual QA sign-off (for major features)

### Pre-Deploy Gates (Production)

**Before deploying to production:**
- ✅ Staging deployment successful for [N] hours
- ✅ Full E2E test suite passes in staging
- ✅ Performance tests pass
- ✅ Security scan passes
- ✅ Product/Engineering manager approval

---

## Test Environments

### Environment Types

| Environment | Purpose | Data | Deployed From | Uptime Requirement |
|-------------|---------|------|---------------|-------------------|
| **Local** | Developer testing | Synthetic test data | Developer machine | N/A |
| **CI** | Automated testing | Ephemeral test data | Every PR | N/A |
| **Dev/Integration** | Integration testing | Synthetic test data | `main` branch (continuous) | Low |
| **Staging** | Pre-production validation | Anonymized production data or synthetic | Release candidates | High |
| **Production** | Live customer traffic | Real customer data | Tagged releases | Critical |

### Environment Parity

**Staging MUST:**
- Mirror production architecture (same services, same infrastructure)
- Use same configuration (except API keys, database connections)
- Run same monitoring and alerting
- Test deployment automation (deploy to staging = deploy to prod)

**Differences between Staging and Production:**
- Smaller instance sizes (cost optimization)
- Synthetic or anonymized data (privacy/compliance)
- May use test external services (payment gateways, email, etc.)

---

## Bug Management

### Bug Severity Levels

| Severity | Definition | SLA | Examples |
|----------|------------|-----|----------|
| **Critical** | System down, data loss, security breach | Fix immediately | Complete outage, payment processing broken |
| **High** | Core feature broken, major degradation | Fix within 24 hours | Login failing for subset of users, slow query causing timeouts |
| **Medium** | Feature partially broken, workaround exists | Fix within 1 week | UI bug, non-critical API 500 errors |
| **Low** | Minor issue, cosmetic problem | Fix when capacity allows | Typos, color inconsistency |

### Bug Workflow

1. **Report**: Create ticket with repro steps, severity, affected users
2. **Triage**: Engineering manager assigns severity and owner within [N] hours
3. **Fix**: Engineer fixes based on SLA
4. **Review**: Code reviewed and tested
5. **Deploy**: Deployed to production
6. **Verify**: QA or reporter verifies fix

**Critical Bug Process:**
- Immediately notify on-call engineer and engineering manager
- Create incident (see `/docs/processes/incident-response.md`)
- Fix in production ASAP (may skip normal review for emergency)
- Retrospective required after resolution

### Regression Prevention

**After fixing a bug:**
- **Must**: Add test that would have caught the bug
- **Should**: Review why existing tests didn't catch it
- **May**: Expand test coverage for similar scenarios

---

## Manual Testing

### When Manual Testing is Appropriate

**Manual testing is valuable for:**
- Exploratory testing (finding unknown issues)
- Usability testing (how users experience the product)
- Edge cases that are hard to automate
- Visual/design validation

**Manual testing is NOT appropriate for:**
- Regression testing (automate instead)
- Repetitive test cases
- API testing (use automation)

### Manual Test Process

**For major features:**
1. QA engineer reviews PRD and creates test plan
2. Manual exploratory testing in staging
3. Document findings and bugs
4. Sign-off when acceptance criteria met

**For minor changes:**
- Engineer performs manual smoke test
- No dedicated QA involvement unless risky

---

## Test Data Management

### Test Data Principles

**Must:**
- Never use production data in non-production environments (privacy/compliance)
- Use realistic, representative test data
- Automate test data creation (scripts, factories, seeders)

**Should:**
- Create test data that covers edge cases
- Reset test data between test runs (avoid flaky tests)

### Sensitive Data in Tests

**Prohibited:**
- Real customer names, emails, phone numbers
- Real credit card numbers, SSNs, or PII
- Real API keys, passwords, or secrets

**Allowed:**
- Synthetic/fake data (faker libraries)
- Anonymized production data (all PII removed or obfuscated)
- Test account credentials (clearly marked as test, never production)

---

## Monitoring and Observability

### Production Monitoring Requirements

**All production services MUST:**
- Emit metrics (request rate, latency, error rate, saturation)
- Log errors and warnings (structured JSON logs)
- Support distributed tracing
- Have dashboards showing health

**Alerting:**
- **Must**: Alert on critical errors (page on-call)
- **Should**: Alert on degraded performance
- **Should**: Alert on unusual patterns (anomaly detection)

### Measuring Quality in Production

**Key Metrics:**
- **Error Rate**: % of requests that result in errors
- **Uptime**: % of time service is available (SLA: [X]%)
- **Mean Time to Recovery (MTTR)**: How fast we fix outages
- **Change Failure Rate**: % of deployments causing incidents

**Targets:**
- Error rate: < [X]%
- Uptime: > [Y]% (e.g., 99.9%)
- MTTR: < [N] hours
- Change failure rate: < [Z]%

---

## Continuous Improvement

### Quality Metrics Review

**Monthly:**
- Review test coverage trends
- Review bug trends (severity, time to fix)
- Review flaky test rate

**Quarterly:**
- Review quality processes
- Identify bottlenecks
- Update standards if needed

### Post-Incident Reviews

**After every critical incident:**
- Conduct blameless post-mortem (see `/docs/processes/blameless-post-mortem-process.md`)
- Identify root cause and contributing factors
- Create action items to prevent recurrence
- Update runbooks and alerts

---

## Tools and Automation

### Required Tools

**Testing Frameworks:**
- [Language]: [Framework] (e.g., Python: pytest, Go: testing package)

**Test Coverage:**
- [Tool] (e.g., coverage.py, go test -cover)

**Security Scanning:**
- SAST: [Tool] (e.g., Semgrep, SonarQube)
- Dependency: [Tool] (e.g., Snyk, Dependabot)

**Performance Testing:**
- [Tool] (e.g., k6, JMeter, Locust)

**E2E Testing:**
- Web: [Tool] (e.g., Playwright)
- API: [Tool] (e.g., Postman, RestAssured)

### CI/CD Integration

**All tests MUST:**
- Run automatically on every PR
- Fail fast (stop at first failure to save time)
- Report results clearly (which tests failed, why)

---

<!-- LLM: When reviewing code, always check for appropriate test coverage. If tests are missing, suggest specific test cases to add. If tests are flaky or slow, suggest improvements. Quality is not optional - help enforce these standards consistently but constructively. -->
