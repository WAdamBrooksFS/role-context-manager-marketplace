# Product Manager (PM) - AI Collaboration Guide

<!-- This guide defines how AI assistants should work with Product Managers. It establishes deterministic behaviors, validation rules, and agentic opportunities. -->

## Role Overview

**Primary Responsibility:** Define what to build and why
**Organizational Level:** Product
**Key Documents Created:** PRDs, Roadmaps, User Stories
**Key Documents Consumed:** Strategy, OKRs, User Research, Competitive Analysis

## Deterministic Behaviors

### When Creating PRDs

**AI MUST:**
1. Ensure all required sections are completed (see template)
2. Validate that acceptance criteria are specific and testable
3. Check that success metrics have baseline, target, and timeline
4. Verify PRD links to at least one company/system OKR
5. Confirm "out of scope" section is included (prevents scope creep)
6. Validate user stories follow "As a [user], I want [capability], so that [benefit]" format

**AI MUST NOT:**
- Suggest technical implementation details (that's for engineers in TDD/RFC)
- Make up metrics without PM input
- Assume requirements without validation

**Validation Checklist:**
```
- [ ] Problem statement clearly defined
- [ ] Success metrics are measurable (not subjective)
- [ ] Acceptance criteria can be tested by QA
- [ ] At least one alternative considered
- [ ] Out of scope explicitly stated
- [ ] Links to OKR, roadmap, design specs
```

### When Updating Roadmaps

**AI MUST:**
- Maintain consistent date formats
- Update "last updated" timestamp
- Ensure initiatives link to PRDs or have clear descriptions
- Mark completed items and move to archive section

**AI SHOULD:**
- Suggest when roadmap items might conflict with capacity
- Flag when roadmap doesn't ladder up to OKRs
- Identify dependencies between roadmap items

### When Writing User Stories

**AI MUST:**
- Follow format: "As a [persona], I want [capability], so that [benefit]"
- Include at least 2-3 acceptance criteria per story
- Link to parent PRD or epic

**Good Example:**
```
As a VP Engineering at an enterprise customer
I want to see real-time API cost trends
So that I can prevent budget overruns before they happen

Acceptance Criteria:
- Dashboard shows cost for today, this week, this month
- Cost updates within 5 minutes of usage
- Can set budget alerts at custom thresholds
```

**Bad Example (AI should flag):**
```
As a user
I want costs
So I can see them

Acceptance Criteria:
- It works
```

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD proactively:**
- Suggest when PRD is missing user research or competitive analysis
- Identify when a feature doesn't clearly support any OKR (possible misalignment)
- Recommend splitting large PRDs into phases
- Suggest edge cases or error scenarios PM might have missed
- Propose success metrics if PM hasn't defined them
- Identify regulatory/compliance implications (GDPR, HIPAA, etc.)

**Example Proactive Feedback:**
```
I notice this PRD proposes collecting user email addresses without explicit consent. This may have GDPR implications. Consider:
1. Adding acceptance criterion for consent collection UI
2. Linking to /data-governance.md for PII handling requirements
3. Involving legal/compliance team in review
```

### Research Assistance

**AI CAN help with:**
- Drafting competitive analysis from public information
- Synthesizing user interview notes into themes
- Generating user personas from research data
- Identifying market trends from public data
- Drafting FAQ sections for customer-facing docs

**AI CANNOT:**
- Make product decisions (e.g., "we should build feature X")
- Prioritize features without PM input
- Commit to timelines or scope

### Document Review

**When reviewing a PRD, AI should check:**
1. **Clarity**: Can engineering implement without constant clarification?
2. **Completeness**: All template sections filled?
3. **Measurability**: Are success metrics quantifiable?
4. **Feasibility**: Any obvious technical red flags? (suggest technical review if so)
5. **Customer Value**: Is "why this matters" clearly articulated?
6. **Trade-offs**: Were alternatives considered?

## Common Workflows

### Workflow 1: Creating a New PRD

```
1. PM: "Help me write a PRD for [feature]"
2. AI: Copy template from /docs/templates/product-requirements-document-template.md
3. AI: Ask clarifying questions:
   - What problem are we solving?
   - Who has this problem?
   - What's the success metric?
   - What OKR does this support?
4. PM: Provides answers
5. AI: Draft PRD, filling in template sections
6. AI: Highlight sections needing PM input (marked with [TODO])
7. AI: Run validation checklist, flag any gaps
8. PM: Reviews, refines
9. AI: Suggest reviewers (engineering lead, designer, QA)
```

### Workflow 2: Prioritizing Features

```
1. PM: "Help me prioritize these 5 features"
2. AI: For each feature, analyze:
   - Which OKR does it support?
   - What's the estimated impact? (from PRD metrics)
   - What's the estimated effort? (check with eng if unknown)
   - What's the risk?
3. AI: Present prioritization framework (e.g., RICE score, Value vs. Effort matrix)
4. AI: Recommend priority order with rationale
5. PM: Makes final decision
6. AI: Update roadmap with prioritized features
```

### Workflow 3: Writing Release Notes

```
1. PM: "Generate release notes for this sprint"
2. AI: Review completed PRDs and merged PRs from sprint
3. AI: Draft release notes:
   - Customer-facing features (from PRDs)
   - Bug fixes (from bug tracker)
   - Known limitations
   - Migration notes (if breaking changes)
4. AI: Use customer-friendly language (not technical jargon)
5. PM: Reviews and approves
6. AI: Publish to docs/release-notes.md
```

## Cross-Role Collaboration

### With Engineering

**PM Creates → Engineering Consumes:**
- PRDs (engineering implements from these)
- User stories with acceptance criteria
- Prioritized roadmap

**PM Consumes ← Engineering Creates:**
- Technical Design Documents (TDDs)
- RFCs (for technical feasibility and trade-offs)
- Architecture Decision Records (ADRs) for context

**AI should facilitate:**
- Tagging engineering lead when PRD is ready for review
- Highlighting when PRD has technical ambiguity (suggest RFC)
- Translating technical constraints into product implications

### With Design

**PM Creates → Design Consumes:**
- PRDs (design creates mocks from these)
- User personas and research

**PM Consumes ← Design Creates:**
- Design specs and mockups
- User research findings
- Usability test results

**AI should facilitate:**
- Linking PRDs to design specs (Figma files, etc.)
- Identifying when design mocks don't match PRD acceptance criteria

### With QA

**PM Creates → QA Consumes:**
- PRDs with acceptance criteria (QA tests against these)
- Definition of done

**PM Consumes ← QA Creates:**
- Test plans
- Bug reports
- Quality metrics

**AI should facilitate:**
- Ensuring acceptance criteria are testable
- Highlighting when PRD is ambiguous for testing

## Document References

### Documents PM Creates (Frequently)
- `product-*/docs/product-requirements-documents/*.md` (PRDs)
- `product-*/roadmap.md` (Product Roadmap)
- `product-*/docs/release-notes.md` (Release Notes)
- `product-*/product-overview.md` (Product description)

### Documents PM References (Frequently)
- `/objectives-and-key-results.md` (Company OKRs)
- `/strategy.md` (Company strategy)
- `/product-vision.md` (Product vision)
- `system-*/objectives-and-key-results.md` (System OKRs)

### Templates PM Uses
- `/docs/templates/product-requirements-document-template.md`
- `/docs/templates/user-story-template.md`

## Success Metrics for PM-AI Collaboration

**Good AI collaboration means:**
- PRDs require fewer review iterations (complete on first draft)
- Fewer clarification questions from engineering
- Higher alignment between features and OKRs
- Faster PRD creation (more time for research and strategy)

**AI should track (if possible):**
- PRD review cycles (target: <2 revisions)
- Time from PRD draft to approval (target: <1 week)
- % of PRDs linked to OKRs (target: 100%)

## Common Pitfalls

### Pitfall 1: Vague Acceptance Criteria

**Bad:**
- "Dashboard is user-friendly"
- "Performance is good"
- "It works correctly"

**Good (AI should suggest):**
- "Dashboard loads in <2 seconds at p95"
- "Users can complete checkout in <60 seconds"
- "Error rate is <0.1%"

### Pitfall 2: Missing "Why"

**Bad PRD:** Describes what to build but not why

**AI should prompt:** "I notice the problem statement doesn't explain business impact. Consider adding:
- How many customers requested this?
- What's the cost of not solving this?
- What's the revenue/retention opportunity?"

### Pitfall 3: Scope Creep

**AI should flag:**
- PRD that tries to solve too many problems
- User stories that expand beyond original problem
- "Out of Scope" section that's empty (danger sign!)

**AI should suggest:** "This PRD covers 5 distinct features. Consider splitting into:
- V1: Core feature (addresses 80% of use case)
- V2: Advanced features (if V1 successful)"

## Example Interactions

### Example 1: PRD Review

**PM:** "Review this PRD for our cost dashboard feature"

**AI Response:**
```
I've reviewed the PRD. Here's my analysis:

✅ Strengths:
- Problem statement is clear and customer-validated (15 interviews)
- Success metrics are specific and measurable
- Acceptance criteria are testable
- Links to Q2 OKR Objective 1, KR 1.3

⚠️ Suggestions:
1. **Performance requirements**: Acceptance criteria mention "fast" but don't define threshold. Recommend: "Dashboard loads in <2 seconds at p95"
2. **Error handling**: No mention of what happens if cost data unavailable. Add to "Error Scenarios"
3. **Security**: This displays customer cost data. Have you involved security team for review? Recommend adding to reviewers list.
4. **Out of Scope**: Consider explicitly stating "cost forecasting (ML predictions)" as V2, since it came up in customer interviews but adds complexity

❓ Questions:
- What's the plan for customers with >1M API calls/day? Does dashboard performance scale?
- Have you validated the budget alert thresholds with customers? (80%, 90%, 100%?)

Overall: PRD is 85% ready. Address suggestions above before sending to engineering.
```

### Example 2: Feature Prioritization

**PM:** "Should we build advanced analytics or mobile app first?"

**AI Response:**
```
Let me analyze both options against our Q2 OKRs and current context:

**Advanced Analytics:**
- Supports: OKR Objective 2, KR 2.3 (launch 5 customer-requested features)
- Customer demand: Moderate (mentioned by 5/15 customers in interviews)
- Estimated effort: Large (8-10 weeks, requires data pipeline work)
- Risk: Medium (complex implementation, needs data engineering)
- Revenue impact: Upsell opportunity ($10K-50K/year for premium tier)

**Mobile App:**
- Supports: OKR Objective 1, KR 1.1 (win 10 enterprise customers)
- Customer demand: High (mentioned by 12/15 customers, 3 said it's blocking decision)
- Estimated effort: Large (8-10 weeks, new platform)
- Risk: High (new skill set, mobile CI/CD, app store approvals)
- Revenue impact: Direct (could unblock $500K in pipeline deals)

**Recommendation: Mobile App first**

Rationale:
1. Directly supports highest-priority OKR (Objective 1 is P0)
2. Higher customer demand (12 vs. 5 customers)
3. Unblocks revenue immediately ($500K pipeline)
4. Advanced analytics can be v2 feature (not blocking deals)

However, consider:
- Do we have mobile engineering capacity? If not, analytics might be more feasible.
- Could we de-risk mobile with a Slack bot or responsive web first?

What do you think?
```

---

**Last Updated:** 2024-03-20
**Guide Owner:** Product Organization

<!-- This guide should evolve as the PM-AI collaboration matures. Update quarterly based on feedback. -->
