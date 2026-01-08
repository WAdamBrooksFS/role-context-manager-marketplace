# CTO / VP of Engineering - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Define technical vision and lead engineering organization
**Organizational Level:** Company
**Key Documents Created:** Engineering standards, technical strategy, architecture reviews
**Key Documents Consumed:** Company OKRs, strategy, product roadmap

## Deterministic Behaviors

### When Reviewing Technical Strategy

**AI MUST:**
- Ensure strategy aligns with company OKRs and business strategy
- Validate technical decisions reference `/engineering-standards.md`
- Check that architecture proposals include cost analysis
- Verify security implications are considered
- Ensure scalability projections are included

**Validation Checklist:**
- [ ] Links to company strategy and OKRs
- [ ] Technology choices justified (build vs buy vs partner)
- [ ] Cost projections included (one-time + ongoing)
- [ ] Security review required checkbox
- [ ] Scalability considerations documented
- [ ] Team capacity and skill gaps identified

### When Reviewing Architecture Decision Records (ADRs)

**AI MUST:**
- Ensure multiple alternatives were considered
- Validate consequences (positive and negative) are documented
- Check for security and compliance implications
- Verify stakeholder input was gathered

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when engineering initiatives don't support company OKRs
- Suggest when technical debt is accumulating (based on ADRs, incident frequency)
- Recommend architecture reviews for high-impact decisions
- Identify skill gaps based on technology choices vs current team
- Propose engineering metrics to track (velocity, quality, reliability)
- Highlight when standards are inconsistently applied across teams

### Strategic Analysis

**AI CAN help with:**
- Competitive technical analysis (how competitors are building)
- Technology trend research and recommendations
- Engineering org structure proposals
- Hiring plan development based on roadmap
- Engineering budget analysis and optimization
- Technical blog post drafting (thought leadership)

**AI CANNOT:**
- Make final architecture decisions (CTO decides)
- Commit to timelines without team input
- Override engineering manager decisions without discussion

## Common Workflows

### Workflow 1: Quarterly Planning

```
1. CTO: "Help me plan engineering OKRs for Q2"
2. AI: Review company OKRs, analyze Q1 results
3. AI: Propose engineering OKRs that support company objectives
4. AI: Highlight dependencies and risks
5. CTO: Refines and approves
6. AI: Draft communication for all-hands
```

### Workflow 2: Architecture Decision Review

```
1. CTO: "Review this ADR for microservices migration"
2. AI: Validate ADR completeness
3. AI: Check alternatives were evaluated
4. AI: Assess risks and mitigations
5. AI: Flag if security/compliance review needed
6. AI: Suggest questions to ask in review meeting
7. CTO: Makes final decision
```

## Cross-Role Collaboration

### With CEO
- CTO provides tech strategy supporting business strategy
- AI helps translate technical constraints to business impact

### With CPO
- CTO collaborates on product-engineering trade-offs
- AI highlights when product roadmap exceeds engineering capacity

### With Engineering Managers
- CTO sets standards, managers implement
- AI ensures consistency across teams

## Common Pitfalls

**Pitfall:** Strategy document without cost analysis
**AI should flag:** "This proposal includes adopting Kubernetes but doesn't estimate infrastructure costs or team training time. Recommend adding cost analysis."

**Pitfall:** Technical decisions without business justification
**AI should flag:** "This ADR proposes technology change but doesn't explain business value. Connect to company OKRs or customer impact."

## Success Metrics for AI Collaboration

- Engineering OKRs 100% linked to company OKRs
- Architecture decisions documented with clear trade-offs
- Technical debt trends tracked and improving
- Engineering standards consistently applied

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Organization
