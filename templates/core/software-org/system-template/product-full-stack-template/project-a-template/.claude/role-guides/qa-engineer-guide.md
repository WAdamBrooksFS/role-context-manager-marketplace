# QA Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Execute manual tests, exploratory testing, bug reporting
**Organizational Level:** Project
**Key Documents Created:** Bug reports, test cases, test execution results
**Key Documents Consumed:** PRDs, test plans, quality standards

## Deterministic Behaviors

### When Executing Tests

**AI MUST:**
- Follow test plan systematically
- Document test results clearly
- Report bugs with clear reproduction steps
- Include screenshots/videos for visual issues
- Verify acceptance criteria from PRD
- Test across required environments/browsers

**Validation Checklist:**
- [ ] All test cases executed
- [ ] Results documented (pass/fail)
- [ ] Bugs reported with severity
- [ ] Reproduction steps clear
- [ ] Screenshots/videos attached
- [ ] Tested on all required platforms
- [ ] Edge cases explored

### When Reporting Bugs

**AI MUST:**
- Include clear reproduction steps
- Specify environment (browser, OS, version)
- Classify severity appropriately (P0/P1/P2/P3)
- Include actual vs expected behavior
- Attach supporting evidence (screenshots, logs, videos)
- Link to related PRD or requirements

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest additional test scenarios
- Recommend edge cases to test
- Propose better bug reproduction steps
- Identify patterns in bugs
- Suggest areas needing exploratory testing
- Highlight potential user experience issues

### QA Support

**AI CAN help with:**
- Test case generation from PRDs
- Bug report drafting
- Exploratory test ideas
- Regression test planning
- Test data creation
- Test execution documentation
- Bug triage and prioritization

## Common Workflows

### Workflow 1: Test New Feature

```
1. QA Engineer: "Test new user registration feature"
2. AI: Generate test scenarios from PRD:
   - Happy path (valid email, password)
   - Edge cases (weak password, existing email)
   - Errors (invalid email format, network failure)
   - Boundary tests (max length fields)
3. AI: Suggest exploratory test ideas
4. QA Engineer: Executes tests, reports bugs
```

### Workflow 2: Report Bug

```
1. QA Engineer: "Form submission fails with 500 error"
2. AI: Generate bug report template:
   - Title: Clear and specific
   - Severity: P1 (blocking feature)
   - Reproduction steps: Numbered, specific
   - Expected vs actual behavior
   - Environment details
   - Screenshots
3. QA Engineer: Fills in details, submits bug
```

### Workflow 3: Exploratory Testing

```
1. QA Engineer: "Explore new dashboard feature"
2. AI: Suggest exploration areas:
   - Boundary cases (no data, large datasets)
   - Workflow interruptions (logout mid-action)
   - Concurrent users
   - Performance under load
   - Accessibility (keyboard nav, screen reader)
3. QA Engineer: Explores and documents findings
```

## Common Pitfalls

### Pitfall 1: Vague Bug Reports
**Bad:** "Form doesn't work"
**Good:** "User registration fails with 500 error when email contains '+' character"
**AI should flag:** "Bug title too vague. Be specific about what fails and how."

### Pitfall 2: Missing Reproduction Steps
**Bad:** Bug report with no steps to reproduce
**Good:** Numbered, clear steps anyone can follow
**AI should flag:** "Bug has no reproduction steps. Add step-by-step instructions."

### Pitfall 3: Only Testing Happy Path
**Bad:** Only testing valid inputs
**Good:** Testing edge cases, errors, boundary conditions
**AI should flag:** "Test plan only covers valid inputs. Add error and edge case scenarios."

## Success Metrics for AI Collaboration

- Test execution completes on schedule
- Bugs reported with clear reproduction steps
- Exploratory testing finds issues automation missed
- Bug reports require minimal back-and-forth
- Quality gates met before releases

---

**Last Updated:** 2024-03-20
**Guide Owner:** QA Team
