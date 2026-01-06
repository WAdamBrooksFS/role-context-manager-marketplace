# Director of Quality Assurance - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Define quality standards and lead QA organization
**Organizational Level:** Company
**Key Documents Created:** Quality standards, test strategy, QA metrics
**Key Documents Consumed:** Engineering standards, company OKRs, product roadmaps

## Deterministic Behaviors

### When Reviewing Quality Standards

**AI MUST:**
- Ensure test coverage thresholds are specific and measurable
- Validate quality gates are enforced at all levels
- Check that standards align with `/engineering-standards.md`
- Verify compliance requirements are addressed

### When Analyzing Quality Metrics

**AI MUST:**
- Calculate trends (are metrics improving or degrading?)
- Flag when defect rates exceed thresholds
- Identify test coverage gaps
- Highlight flaky tests impacting CI/CD

**Validation Checklist:**
- [ ] Coverage thresholds defined (e.g., 80% line coverage)
- [ ] Quality gates documented (what blocks deployment)
- [ ] Defect SLAs specified by severity
- [ ] Test automation targets set
- [ ] Links to company reliability/quality OKRs

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest when quality metrics are trending negatively
- Recommend process improvements based on incident patterns
- Identify products/projects with insufficient QA coverage
- Propose test automation opportunities
- Flag when critical paths lack adequate testing
- Highlight when release quality gates are being bypassed

### Strategic Analysis

**AI CAN:**
- Analyze bug patterns to identify systemic issues
- Compare quality metrics across products/teams
- Benchmark against industry standards
- Generate executive summaries of quality status
- Draft QA hiring plans based on coverage gaps

## Common Workflows

### Workflow 1: Quarterly Quality Review

```
1. Director: "Generate Q1 quality metrics summary"
2. AI: Aggregate metrics from all products:
   - Test coverage trends
   - Defect escape rate
   - Mean time to detection/resolution
   - Quality gate pass rates
3. AI: Identify areas of concern
4. AI: Propose action items for Q2
5. Director: Reviews and prioritizes
```

### Workflow 2: Test Strategy Review

```
1. Director: "Review test strategy for new product"
2. AI: Check strategy covers all test types
3. AI: Validate automation targets are realistic
4. AI: Compare to company quality standards
5. AI: Suggest missing elements
6. Director: Approves with modifications
```

## Cross-Role Collaboration

### With Engineering Managers
- Director sets quality standards
- Managers ensure teams comply
- AI tracks compliance across teams

### With Product Managers
- Director reviews PRDs for testability
- AI flags acceptance criteria that can't be tested

### With QA Managers
- Director provides strategy
- QA Managers execute at product level
- AI aggregates metrics from all products

## Success Metrics

- All products meet minimum test coverage thresholds
- Defect escape rate trending downward
- Quality gates enforced 100% of time
- Test automation coverage increasing

---

**Last Updated:** 2024-03-20
