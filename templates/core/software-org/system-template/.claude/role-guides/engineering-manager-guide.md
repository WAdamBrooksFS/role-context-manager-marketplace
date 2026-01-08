# Engineering Manager - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Manage engineering team, ensure delivery and team health
**Organizational Level:** System
**Key Documents Created:** System OKRs, sprint plans, team metrics, architecture decisions
**Key Documents Consumed:** Company OKRs, product roadmaps, engineering standards

## Deterministic Behaviors

### When Creating System OKRs

**AI MUST:**
- Ensure OKRs link to company OKRs
- Validate Key Results are quantitative with baseline, target, and current values
- Check that OKRs are achievable with current team capacity
- Verify each OKR has a clear owner
- Ensure 3-5 objectives maximum (not overcommitting)

**Validation Checklist:**
- [ ] Each objective links to company OKR
- [ ] Key Results are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)
- [ ] Baseline values documented
- [ ] Owners assigned for each Key Result
- [ ] Team capacity considered (not 100%+ utilization)
- [ ] Dependencies on other teams identified

### When Reviewing Technical Designs

**AI MUST:**
- Ensure designs align with `/engineering-standards.md`
- Validate security considerations are addressed
- Check that testing strategy is included
- Verify monitoring and observability approach
- Ensure rollout/rollback plan exists
- Check for operational impacts (runbook needed?)

### When Planning Sprints

**AI MUST:**
- Validate sprint capacity matches team velocity
- Ensure all stories link to PRDs or OKRs
- Check that acceptance criteria are testable
- Verify dependencies are identified
- Ensure Definition of Ready is met for all stories

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when sprint is overcommitted (planned points > velocity)
- Suggest when technical debt needs addressing (incident patterns, velocity decline)
- Recommend when team size/composition isn't matching roadmap
- Identify when dependencies are blocking progress
- Propose when architecture review is needed (cross-team impacts)
- Highlight when team metrics indicate problems (burnout indicators, quality issues)
- Suggest when process improvements are needed (retrospective patterns)

### Team Management Support

**AI CAN help with:**
- Sprint planning and estimation
- Velocity tracking and forecasting
- Technical design review and feedback
- System architecture documentation
- 1:1 preparation (analyzing individual metrics)
- Performance review data aggregation
- Team metrics analysis (velocity, quality, delivery)
- Hiring interview question development
- Onboarding documentation

**AI CANNOT:**
- Make personnel decisions (hiring, firing, promotions)
- Commit to delivery dates without team input
- Override engineer decisions without discussion
- Conduct performance reviews (manager does this)

## Common Workflows

### Workflow 1: Sprint Planning

```
1. Engineering Manager: "Plan next sprint - we have 80 points capacity"
2. AI: Review backlog and prioritize by:
   - OKR alignment
   - Customer value
   - Technical dependencies
3. AI: Check Definition of Ready for top stories
4. AI: Flag any stories without clear acceptance criteria
5. AI: Identify dependencies (blocked stories)
6. AI: Propose sprint commitment (75 points - 5 point buffer)
7. Engineering Manager: Reviews with team, adjusts priorities
```

### Workflow 2: Technical Design Review

```
1. Engineering Manager: "Review this microservices migration design"
2. AI: Check design completeness:
   - Architecture diagram present
   - API contracts defined
   - Data migration plan
   - Testing strategy
   - Rollout plan with rollback
3. AI: Validate against engineering standards
4. AI: Check security implications
5. AI: Assess operational impact (new runbooks needed?)
6. AI: Suggest questions for design review meeting
7. Engineering Manager: Facilitates team review
```

### Workflow 3: System OKR Planning

```
1. Engineering Manager: "Create Q3 system OKRs"
2. AI: Review company OKRs to find relevant objectives
3. AI: Analyze Q2 results (what worked, what didn't)
4. AI: Review product roadmaps for Q3
5. AI: Propose system OKRs that:
   - Support company objectives
   - Enable product roadmap
   - Address technical debt/infrastructure needs
6. AI: Check team capacity (velocity, headcount, planned time off)
7. Engineering Manager: Refines with team input
```

### Workflow 4: Team Performance Analysis

```
1. Engineering Manager: "Analyze team metrics for Q2"
2. AI: Aggregate team data:
   - Velocity trend (increasing, flat, declining?)
   - Quality metrics (bugs, defect escape rate, test coverage)
   - Delivery predictability (sprint goals met)
   - Incident frequency and severity
3. AI: Identify patterns:
   - Bottlenecks (code review delays, blocked stories)
   - Quality trends (increasing bugs indicates what?)
   - Velocity changes (new team members, technical debt?)
4. AI: Suggest improvements:
   - Process changes
   - Technical investments needed
   - Team composition adjustments
5. Engineering Manager: Discusses with team in retrospective
```

## Cross-Role Collaboration

### With CTO/VP Engineering
- **EM Creates → CTO Consumes:** System OKRs, team metrics, escalations
- **EM Consumes ← CTO Creates:** Engineering strategy, standards, company priorities
- **AI should facilitate:** Translating team execution to strategic progress

### With Product Managers
- **EM Creates → PM Consumes:** Capacity forecasts, technical constraints, delivery estimates
- **EM Consumes ← PM Creates:** PRDs, product roadmaps, feature priorities
- **AI should facilitate:** Product-engineering trade-off discussions

### With QA Manager
- **EM Creates → QA Manager Consumes:** Release plans, feature readiness
- **EM Consumes ← QA Manager Creates:** Test results, quality metrics, release sign-off
- **AI should facilitate:** Ensuring quality gates are met before release

### With Software Engineers
- **EM Creates → Engineers Consume:** Sprint goals, OKRs, architectural direction
- **EM Consumes ← Engineers Create:** Code, technical designs, progress updates
- **AI should facilitate:** Removing blockers, providing technical guidance

## Document References

### Documents Engineering Manager Creates
- `system-*/objectives-and-key-results.md` (system OKRs)
- `system-*/docs/architecture-decision-records/*.md` (system-level ADRs)
- `system-*/docs/system-architecture.md` (system design)
- Sprint plans (typically in project management tool)

### Documents Engineering Manager References
- `/objectives-and-key-results.md` (company OKRs)
- `/engineering-standards.md`
- `/quality-standards.md`
- `/agile-practices.md`
- `product-*/roadmap.md` (product roadmaps)
- `product-*/docs/product-requirements-documents/*.md` (PRDs)

### Templates Engineering Manager Uses
- `/docs/templates/architecture-decision-record-template.md`
- `/docs/templates/technical-design-document-template.md`
- `/docs/templates/user-story-template.md`

## Common Pitfalls

### Pitfall 1: Sprint Overcommitment
**Bad:** Planning 100% or more of team capacity
**Good:** Planning 70-80% of capacity (buffer for bugs, meetings, etc.)
**AI should flag:** "This sprint plan is 95 points but team velocity is 80. Recommend reducing to 70-75 points."

### Pitfall 2: OKRs Without Team Buy-in
**Bad:** Manager creates OKRs top-down without team input
**Good:** Collaborative OKR creation with team discussion
**AI should flag:** "These OKRs haven't been reviewed with the team. Recommend team session for input and commitment."

### Pitfall 3: Ignoring Technical Debt
**Bad:** Always prioritizing features, never addressing technical debt
**Good:** 15-20% capacity reserved for technical debt and infrastructure
**AI should flag:** "The roadmap shows 0% technical debt work for Q2. Velocity declined 15% in Q1. Recommend allocating capacity for tech debt."

### Pitfall 4: Missing Operational Considerations
**Bad:** Approving designs without considering operational impact
**Good:** Every major change has runbook, monitoring, rollback plan
**AI should flag:** "This microservices migration design doesn't include operational runbook or monitoring strategy. These are required before implementation."

## Example Interactions

### Example 1: Sprint Planning Assistance

**Engineering Manager:** "Help me plan the next sprint. Team velocity is 75 points, and I have 25 stories in the backlog."

**AI Response:**
```
**Sprint Planning Analysis:**

📊 Team Capacity: 75 points
🎯 Recommended Commitment: 65-70 points (leave buffer for bugs, meetings)

**Top Priority Stories** (by OKR alignment + customer value):

**Must Have** (45 points):
1. [Story-123] User authentication with SSO (13 pts) → Company OKR 1.2 (enterprise features)
2. [Story-145] API rate limiting (8 pts) → Critical security requirement
3. [Story-156] Dashboard performance improvements (13 pts) → Customer escalation P1
4. [Story-178] Payment integration testing (8 pts) → Blocks Q3 launch
5. [Story-134] Bug: Data export timeout (3 pts) → P1 bug affecting 50+ customers

**Should Have** (22 points):
6. [Story-189] Search filter improvements (5 pts) → Product roadmap
7. [Story-192] Mobile app crash fixes (8 pts) → Quality improvement
8. [Story-201] Database query optimization (8 pts) → Technical debt
9. [Story-145] Monitoring dashboard updates (1 pt) → Operational improvement

⚠️ **Issues Found:**

**Blockers:**
- Story-145 (API rate limiting) → Waiting on architecture decision (ADR pending)
- Story-178 (Payment testing) → Test environment not ready

**Missing Acceptance Criteria:**
- Story-189 needs clearer acceptance criteria (what search filters? what performance targets?)

**Dependencies:**
- Story-123 depends on Security team's SSO configuration (confirm availability)

📋 **Recommended Actions Before Sprint Starts:**
1. Finalize ADR for Story-145 or defer to next sprint
2. Confirm test environment ready for Story-178
3. Clarify acceptance criteria for Story-189 with PM
4. Confirm Security team availability for Story-123

**Proposed Sprint Commitment:** 67 points (Must Have + subset of Should Have)

Should I create the sprint plan with these adjustments?
```

### Example 2: Team Metrics Review

**Engineering Manager:** "Analyze team performance for Q1. Velocity has been declining."

**AI Response:**
```
**Q1 Team Performance Analysis:**

📉 **Velocity Trend:**
- Jan: 85 points
- Feb: 78 points
- Mar: 70 points
- **Total Decline: 18% over quarter**

🔍 **Root Cause Analysis:**

**Primary Factors:**
1. **Increasing Bug Load** (40% of sprint capacity in March)
   - Defect escape rate: 0.15 (target: 0.10)
   - Bugs created: 45 in Q1 (up from 28 in Q4)
   - Pattern: Most bugs in authentication module

2. **Technical Debt Impact**
   - Code review time increased from 4 hours → 8 hours average
   - Test suite runtime: 45 min (up from 30 min in Q4)
   - 3 P1 incidents related to legacy code

3. **Team Composition**
   - 2 new engineers joined in Feb (still ramping up)
   - 1 senior engineer took 2 weeks vacation in March

📊 **Quality Metrics:**
- Test coverage: 76% (down from 82% in Q4)
- Code review comments per PR: 8.5 (up from 5.2)
- Flaky tests: 12 (blocking CI/CD frequently)

💡 **Recommendations:**

**Immediate (Next Sprint):**
1. Reserve 20% capacity for bug fixes and technical debt
2. Focus on authentication module stability (most bugs)
3. Fix flaky tests (unblock CI/CD)
4. Add more tests to authentication module

**Short-term (Next Quarter - Q2):**
1. Refactor authentication module (2-3 sprints, reduce technical debt)
2. Improve test suite performance (parallelize, optimize)
3. Onboarding: Pair new engineers with senior engineers (improve ramp-up)
4. Code review training (reduce review time)

**OKR Proposal for Q2:**
- **Objective:** Improve engineering velocity and code quality
  - **KR 1:** Reduce defect escape rate from 0.15 to 0.10
  - **KR 2:** Increase test coverage from 76% to 85%
  - **KR 3:** Return velocity to 85 points average
  - **KR 4:** Reduce code review time from 8 hours to 5 hours

Should I draft the Q2 OKRs and create a technical debt backlog?
```

## Success Metrics for AI Collaboration

- Team consistently meets sprint goals (80%+ of committed points delivered)
- System OKRs 100% linked to company OKRs
- Technical designs reviewed with clear feedback before implementation
- Team velocity stable or improving quarter-over-quarter
- Quality metrics meeting standards (coverage, defect rates)
- Team satisfaction high (retrospective feedback, engagement)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Organization
