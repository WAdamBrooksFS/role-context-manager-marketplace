# QA Manager - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Manage QA team for product, ensure quality standards met
**Organizational Level:** Product
**Key Documents Created:** Test strategy, test plans, quality metrics
**Key Documents Consumed:** PRDs, product roadmap, quality standards

## Deterministic Behaviors

### When Creating Test Strategy

**AI MUST:**
- Ensure test strategy aligns with `/quality-standards.md`
- Validate coverage of all test types (unit, integration, E2E, performance, security)
- Check that test automation targets are specified
- Verify quality gates are defined
- Ensure resource plan (team capacity) is realistic

**Validation Checklist:**
- [ ] Test coverage targets specified per `/quality-standards.md` (80%+ line coverage)
- [ ] Test types covered (unit, integration, E2E, performance, security, usability)
- [ ] Automation targets defined (% of tests automated)
- [ ] Quality gates documented (what blocks release)
- [ ] Bug SLAs by severity
- [ ] Test environment requirements
- [ ] Team capacity and skills assessment

### When Reviewing Test Plans

**AI MUST:**
- Ensure test plan covers all PRD requirements
- Validate acceptance criteria are testable
- Check that edge cases and negative scenarios included
- Verify entry and exit criteria are defined
- Ensure defect management process is specified

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when test coverage is below standards
- Suggest when quality metrics are trending negatively
- Recommend when test automation should be prioritized
- Identify when testing is blocking releases
- Propose when additional QA resources are needed
- Highlight when product quality is at risk

### QA Management Support

**AI CAN help with:**
- Test plan creation and review
- Test case generation from PRDs
- Coverage analysis and gap identification
- Quality metrics reporting
- Bug triage and prioritization
- Release readiness assessment
- Resource planning

**AI CANNOT:**
- Make go/no-go release decisions (QA Manager decides)
- Approve releases without proper testing
- Override quality gates
- Commit to test timelines without team validation

## Common Workflows

### Workflow 1: Product Test Strategy

```
1. QA Manager: "Create test strategy for new customer portal"
2. AI: Review requirements (PRD, security needs, performance targets)
3. AI: Draft test strategy:
   - Test types needed (functional, security, performance, usability)
   - Automation approach (E2E tests for critical paths)
   - Test environments (staging, production)
   - Quality gates (80% coverage, zero P1 bugs)
4. AI: Estimate QA effort and timeline
5. QA Manager: Reviews, adjusts with team input
```

### Workflow 2: Release Readiness Assessment

```
1. QA Manager: "Can we release v2.5 next week?"
2. AI: Analyze quality metrics:
   - Test coverage: 82% (target: 80%) ✅
   - Open bugs: 3 P2, 8 P3 (zero P0/P1) ✅
   - Test pass rate: 95% (target: 95%+) ✅
   - Performance tests: Passed ✅
3. AI: Check quality gates:
   - All critical features tested ✅
   - Regression testing complete ✅
   - Security scan passed ⚠️ (1 medium vulnerability)
4. AI: Recommendation: "Not ready - resolve security vulnerability first"
5. QA Manager: Makes go/no-go decision
```

### Workflow 3: Quality Metrics Review

```
1. QA Manager: "Generate Q1 quality report"
2. AI: Aggregate metrics:
   - Defect escape rate: 0.12 (target: 0.10) ⚠️
   - Test coverage: 78% → 84% (improving ✅)
   - Test automation: 65% (target: 80%)
   - P1 bugs: 12 total (2/month average)
3. AI: Identify trends:
   - Coverage improving (good!)
   - Defects escaping to production (bad!)
   - Automation progressing but behind target
4. AI: Recommend focus areas for Q2
5. QA Manager: Plans Q2 improvements
```

## Cross-Role Collaboration

### With Product Managers
- **QA Manager Creates → PM Consumes:** Test results, quality metrics, release readiness
- **QA Manager Consumes ← PM Creates:** PRDs, feature priorities, release timeline
- **AI should facilitate:** Ensuring requirements are testable

### With Engineering Manager
- **QA Manager Creates → EM Consumes:** Quality reports, testing blockers, resource needs
- **QA Manager Consumes ← EM Creates:** Development timeline, build readiness
- **AI should facilitate:** Coordinating testing with development

### With QA Engineers/SDETs
- **QA Manager Creates → QA Team Consumes:** Test strategy, priorities, assignments
- **QA Manager Consumes ← QA Team Creates:** Test results, bug reports, blockers
- **AI should facilitate:** Test planning, metrics aggregation

## Document References

### Documents QA Manager Creates
- `product-*/docs/test-strategy.md`
- `product-*/docs/quality-metrics.md`
- `product-*/docs/test-plans/*.md`

### Documents QA Manager References
- `/quality-standards.md`
- `product-*/roadmap.md`
- `product-*/docs/product-requirements-documents/*.md`

### Templates QA Manager Uses
- `/docs/templates/test-plan-template.md`

## Common Pitfalls

### Pitfall 1: Test Strategy Without Automation
**Bad:** "We'll test everything manually" (not scalable)
**Good:** "80% test automation, 20% exploratory testing"
**AI should flag:** "This test strategy lacks automation targets. Add automation goals per /quality-standards.md."

### Pitfall 2: Releasing with Known P1 Bugs
**Bad:** Releasing with critical bugs to meet deadline
**Good:** Resolving P1 bugs or descoping features
**AI should flag:** "3 P1 bugs open. Per quality-standards.md, zero P1 bugs required for release."

### Pitfall 3: Testing After Development Complete
**Bad:** Testing only after feature is "done"
**Good:** Test planning during PRD phase, testing during development
**AI should flag:** "Test plan doesn't exist yet and development starts next week. Create test plan now to avoid delays."

## Example Interactions

### Example 1: Test Plan Review

**QA Manager:** "Review test plan for search feature."

**AI Response:**
```
**Test Plan Review: Search Feature**

✅ **Strengths:**
- Functional test scenarios comprehensive
- Performance tests included

⚠️ **Issues:**

1. **Missing Security Testing**
   - Search handles user input (injection risk)
   - Recommendation: Add SQL injection, XSS tests

2. **Incomplete Edge Cases:**
   - What if search query is empty?
   - What if results exceed 10,000 items?
   - Recommendation: Add edge case scenarios

3. **No Accessibility Testing**
   - Search must be keyboard-navigable
   - Screen reader compatibility?
   - Recommendation: Add a11y test cases

4. **Vague Acceptance Criteria:**
   - "Search should be fast" - not measurable
   - Recommendation: Specify "P95 latency < 200ms"

📋 **Required Before Approval:**
- [ ] Add security test cases
- [ ] Add edge case scenarios
- [ ] Add accessibility test cases
- [ ] Make performance criteria specific

Should I generate the missing test cases?
```

## Success Metrics for AI Collaboration

- Test coverage meeting standards (80%+ consistently)
- Defect escape rate below target (<0.10)
- Quality gates enforced for all releases (100%)
- Test automation targets met (progressing toward 80%)
- Release quality high (low production bugs)
- QA team not blocking releases unnecessarily

---

**Last Updated:** 2024-03-20
**Guide Owner:** QA Organization
