# SDET (Software Development Engineer in Test) - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build test automation frameworks, write automated tests
**Organizational Level:** Project
**Key Documents Created:** Test automation code, framework documentation, test reports
**Key Documents Consumed:** PRDs, test plans, quality standards, engineering standards

## Deterministic Behaviors

### When Building Test Automation

**AI MUST:**
- Follow engineering standards from `/engineering-standards.md`
- Follow quality standards from `/quality-standards.md`
- Ensure tests are reliable (not flaky)
- Include proper wait strategies (not hardcoded sleeps)
- Generate clear test reports
- Ensure tests are maintainable
- Include test data management strategy

**Validation Checklist:**
- [ ] Tests follow page object model or similar pattern
- [ ] No hardcoded waits (use explicit waits)
- [ ] Tests are independent (can run in any order)
- [ ] Test data properly managed
- [ ] Clear assertion messages
- [ ] Tests integrated into CI/CD pipeline
- [ ] Test reports generated
- [ ] Flaky tests identified and fixed

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest test coverage improvements
- Recommend framework enhancements
- Flag flaky tests
- Identify test code duplication
- Propose better test patterns
- Highlight gaps in automation

### Test Automation Support

**AI CAN help with:**
- Test code generation
- Framework design
- Flaky test debugging
- Test data management
- CI/CD integration
- Test report generation
- Coverage analysis
- Performance test automation

## Common Workflows

### Workflow 1: Automate New Feature

```
1. SDET: "Automate tests for new search feature"
2. AI: Review PRD and test plan
3. AI: Generate test automation:
   - Page objects for search UI
   - Test cases (happy path, edge cases, errors)
   - Test data setup/teardown
4. AI: Integrate into CI/CD pipeline
5. SDET: Reviews, runs tests, adjusts as needed
```

### Workflow 2: Fix Flaky Test

```
1. SDET: "Test failing intermittently, fix it"
2. AI: Analyze test:
   - Hardcoded waits?
   - Race conditions?
   - Test data conflicts?
   - External dependencies?
3. AI: Identify root cause (hardcoded sleep too short)
4. AI: Fix with explicit wait for element visibility
5. SDET: Validates fix over multiple runs
```

## Common Pitfalls

### Pitfall 1: Flaky Tests
**Bad:** Tests pass/fail randomly
**Good:** Reliable tests that pass consistently
**AI should flag:** "Test uses hardcoded sleep. Replace with explicit wait for element."

### Pitfall 2: Tests Depend on Each Other
**Bad:** Test B fails if Test A doesn't run first
**Good:** Independent tests that can run in any order
**AI should flag:** "Test uses state from previous test. Add setup to make test independent."

### Pitfall 3: Poor Test Maintainability
**Bad:** Duplicated code, hardcoded selectors throughout
**Good:** Page objects, reusable methods, clear structure
**AI should flag:** "Selector duplicated across 5 tests. Extract to page object."

## Document References

### Documents SDET Creates
- Test automation code (in version control)
- Page objects and test utilities
- `docs/test-plans/*.md` (test plans and strategies)
- Test framework documentation
- Test reports and metrics
- CI/CD test configuration

### Documents SDET References
- `/engineering-standards.md`
- `/quality-standards.md`
- `/security-policy.md`
- `contributing.md` (project-level)
- `development-setup.md` (project-level)
- PRDs from product team
- User stories and acceptance criteria

### Templates SDET Uses
- `/docs/templates/test-plan-template.md`
- `/docs/templates/user-story-template.md`

---

## Success Metrics for AI Collaboration

- Test automation coverage meets targets (80%+)
- Tests reliable (< 1% flakiness rate)
- Tests run quickly (CI/CD not blocked)
- Test code maintainable and well-structured
- Bugs caught before production

---

**Last Updated:** 2024-03-20
**Guide Owner:** QA Team
