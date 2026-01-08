# Technical Program Manager (TPM) - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Coordinate cross-team initiatives, manage program execution
**Organizational Level:** System
**Key Documents Created:** Program plans, status reports, dependency maps, risk registers
**Key Documents Consumed:** Product roadmaps, technical designs, system OKRs

## Deterministic Behaviors

### When Creating Program Plans

**AI MUST:**
- Ensure program aligns with system or company OKRs
- Validate all dependencies between teams are identified
- Check that milestones have clear success criteria
- Verify resource allocation is realistic
- Ensure risks are identified with mitigation plans
- Validate stakeholder communication plan exists
- Check that program timeline accounts for dependencies

**Validation Checklist:**
- [ ] Program objective links to OKRs
- [ ] All teams involved are identified with clear roles
- [ ] Dependencies mapped (what blocks what)
- [ ] Milestones defined with dates and success criteria
- [ ] Resource capacity validated (teams have bandwidth)
- [ ] Risks identified with probability, impact, and mitigation
- [ ] Communication plan (stakeholders, frequency, format)
- [ ] Success metrics defined (how to measure program success)

### When Tracking Program Status

**AI MUST:**
- Identify blocked work items and dependencies
- Flag when milestones are at risk
- Track completion percentage realistically
- Highlight risks that need escalation
- Ensure status updates include next steps
- Check that issues have owners and due dates

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when program is off track (milestone delays)
- Suggest when dependencies are causing delays
- Recommend when scope should be adjusted
- Identify when resource constraints threaten delivery
- Propose when risks need escalation
- Highlight when communication to stakeholders is overdue
- Suggest when cross-team coordination meetings are needed

### Program Management Support

**AI CAN help with:**
- Dependency mapping and critical path analysis
- Risk assessment and mitigation planning
- Status report generation
- Stakeholder communication drafting
- Resource allocation analysis
- Timeline forecasting
- Meeting agenda and notes
- Decision tracking

**AI CANNOT:**
- Make program scope decisions (TPM with stakeholders decides)
- Commit teams to work without their agreement
- Resolve resource conflicts across teams
- Make technical decisions (engineering teams decide)

## Common Workflows

### Workflow 1: Program Kickoff

```
1. TPM: "Plan cross-team program: migrate all services to Kubernetes"
2. AI: Gather information:
   - Which teams/services involved? (8 teams, 25 services)
   - Timeline? (6 months)
   - Dependencies? (platform team provides K8s, other teams migrate)
3. AI: Create program plan:
   - Phase 1: Platform prep (K8s cluster, monitoring, docs)
   - Phase 2: Pilot migrations (2 services)
   - Phase 3: Remaining migrations (23 services, phased)
   - Dependencies: Each migration depends on Phase 1 complete
4. AI: Identify risks:
   - Platform team capacity constraint
   - Service-specific migration complexity
   - Downtime during cutover
5. AI: Draft communication plan:
   - Weekly updates to engineering leadership
   - Bi-weekly sync with all teams
   - Slack channel for coordination
6. TPM: Refines plan with team input
```

### Workflow 2: Weekly Status Update

```
1. TPM: "Generate weekly program status for Kubernetes migration"
2. AI: Aggregate data:
   - Milestones: Phase 1 complete, Phase 2 in progress (2/2 pilots done)
   - Progress: 12/25 services migrated (48%)
   - Blockers: Team C blocked on database migration approach
   - Risks: Team D at capacity, migration may slip 2 weeks
3. AI: Generate status report:
   - Executive summary (Red/Yellow/Green status)
   - Progress vs plan
   - Blockers and mitigation
   - Upcoming milestones
   - Ask for decisions needed
4. TPM: Reviews, adds context, sends to stakeholders
```

### Workflow 3: Dependency Management

```
1. TPM: "Feature X depends on API from Team A. Team A just delayed 2 weeks. Impact?"
2. AI: Analyze dependencies:
   - Feature X (Team B) depends on API (Team A)
   - Feature X is on critical path for Q2 OKR
   - 4 other features also depend on this API
3. AI: Assess impact:
   - Feature X delayed 2 weeks (misses Q2)
   - 4 other features also at risk
   - Q2 OKR now in jeopardy
4. AI: Recommend options:
   - Option 1: Descope features to meet Q2 (partial delivery)
   - Option 2: Move Q2 OKR to Q3
   - Option 3: Add resources to Team A (expedite API)
5. TPM: Escalates to leadership with options
```

## Cross-Role Collaboration

### With Engineering Managers
- **TPM Creates → EMs Consume:** Program plan, team assignments, timelines
- **TPM Consumes ← EMs Create:** Team capacity, technical constraints, status updates
- **AI should facilitate:** Resource allocation, dependency management

### With Product Managers
- **TPM Creates → PMs Consume:** Program timeline, risk updates, dependency status
- **TPM Consumes ← PMs Create:** Product requirements, feature priorities
- **AI should facilitate:** Aligning program execution with product goals

### With Technical Leads
- **TPM Creates → Tech Leads Consume:** Technical coordination needs, integration points
- **TPM Consumes ← Tech Leads Create:** Technical designs, effort estimates, blockers
- **AI should facilitate:** Technical dependency resolution

### With Leadership (CTO, CPO)
- **TPM Creates → Leadership Consumes:** Program status, risk escalations, decisions needed
- **TPM Consumes ← Leadership Creates:** Program priorities, strategic direction
- **AI should facilitate:** Executive reporting, risk communication

## Document References

### Documents TPM Creates
- `system-*/docs/program-plans/*.md`
- Program status reports (typically in PM tools or docs)
- Risk registers (typically in PM tools)
- Dependency maps (diagrams)

### Documents TPM References
- `/objectives-and-key-results.md` (company OKRs)
- `system-*/objectives-and-key-results.md` (system OKRs)
- `product-*/roadmap.md` (product roadmaps)
- `project-*/docs/technical-design-document.md` (technical designs)

### Templates TPM Uses
- `/docs/templates/technical-design-document-template.md` (for program design)

## Common Pitfalls

### Pitfall 1: Ignoring Dependencies
**Bad:** Planning work in parallel without checking dependencies
**Good:** Mapping all dependencies, identifying critical path
**AI should flag:** "Feature A depends on API from Team B. Team B's API isn't scheduled until Week 6, but Feature A is planned for Week 4. Adjust timeline."

### Pitfall 2: Unrealistic Timeline
**Bad:** Aggressive timeline without team validation
**Good:** Bottom-up estimates from teams, buffer for unknowns
**AI should flag:** "This program timeline shows 20 weeks of work in 12 weeks. Teams estimate 20 weeks minimum. Adjust scope or timeline."

### Pitfall 3: Tracking Output, Not Outcomes
**Bad:** "Team completed 5 stories" (doesn't show program progress)
**Good:** "Phase 1 complete: K8s cluster ready, 2 pilot services migrated successfully"
**AI should flag:** "Status update shows completed tasks but not milestone progress. Report on milestone completion and program health."

### Pitfall 4: Risks Without Mitigation
**Bad:** Identifying risks but no mitigation plan
**Good:** Every risk has probability, impact, mitigation, and owner
**AI should flag:** "5 high-priority risks identified but no mitigation plans. Assign owners and create action items for each."

## Example Interactions

### Example 1: Program Plan Review

**TPM:** "Review the program plan for platform modernization initiative."

**AI Response:**
```
**Program Plan Review: Platform Modernization**

📋 **Program Overview:**
- **Objective:** Migrate from monolith to microservices
- **Timeline:** 9 months
- **Teams:** 6 engineering teams, 1 platform team
- **Scope:** 15 services to extract from monolith

✅ **Strengths:**
- Clear phases (design, pilot, rollout)
- Links to company OKR (improve scalability)
- Resource plan included

⚠️ **Issues to Address:**

**CRITICAL: Missing Dependency Analysis**
- Service extraction order not defined
- Some services depend on others (e.g., Auth service needed first)
- **Recommendation:** Create dependency map, identify critical path

**HIGH: Unrealistic Timeline**
- Phase 2 (pilot): 2 services in 4 weeks
- Based on similar past projects: 3-4 weeks per service realistic
- **Recommendation:** Extend Phase 2 to 8 weeks or reduce to 1 pilot service

**MEDIUM: Incomplete Risk Assessment**
- Only 3 risks identified
- Missing risks:
  - Data migration complexity
  - Performance degradation during transition
  - Team knowledge gaps (microservices patterns)
- **Recommendation:** Comprehensive risk assessment with mitigation plans

**MEDIUM: Vague Success Criteria**
- "Successful migration" is not measurable
- **Recommendation:** Define specific success criteria:
  - All 15 services running in production
  - P95 latency < 200ms (better than monolith)
  - Zero data loss during migrations
  - 99.9% uptime maintained throughout

📊 **Dependency Analysis Needed:**
```
Critical Path:
1. Infrastructure (Platform Team) - 8 weeks
   ├─> 2. Auth Service (Team A) - 4 weeks
   │    ├─> 3. User Service (Team B) - 4 weeks
   │    └─> 4. Payments (Team C) - 4 weeks
   └─> 5. Reporting (Team D) - 4 weeks

Parallel Work:
- Teams E, F can extract non-critical services anytime
```

**Revised Timeline Recommendation:**
- Current: 9 months
- Realistic: 11-12 months (accounting for dependencies + buffer)

📋 **Required Before Approval:**
- [ ] Create service dependency map
- [ ] Adjust timeline based on dependencies
- [ ] Complete risk assessment (identify 8-10 risks)
- [ ] Define measurable success criteria
- [ ] Validate team capacity (can teams handle this + BAU work?)

Should I create the dependency map and revised timeline?
```

### Example 2: Program Status Report Generation

**TPM:** "Generate this week's status report for platform modernization."

**AI Response:**
```
**Weekly Program Status: Platform Modernization**
**Week 12 of 36 | Q2 2024**

🟢 **Overall Status: ON TRACK**

---

📊 **Progress Summary:**

**Milestones Completed:**
- ✅ Infrastructure ready (Week 8) - K8s cluster, monitoring, CI/CD
- ✅ Pilot 1: Auth Service migrated (Week 11)
- 🔄 Pilot 2: User Service (in progress, on track for Week 13)

**Progress vs Plan:**
- Services migrated: 1/15 (7%)
- Timeline: Week 12/36 (33%)
- We're ahead in Phase 1, on track for Phase 2

**Upcoming Milestones:**
- Week 13: Complete Pilot 2 (User Service)
- Week 14: Go/No-Go decision for Phase 3 (full rollout)
- Week 16: Begin Payments Service migration

---

🚧 **Blockers:**

1. **Database Schema Conflicts** (Team B - User Service)
   - **Issue:** User service DB schema conflicts with monolith
   - **Impact:** Pilot 2 at risk (potential 1-week delay)
   - **Mitigation:** DB architect assisting Team B, working session Tues
   - **Owner:** Sarah (Team B Lead)
   - **ETA:** Resolved by end of week

---

⚠️ **Risks:**

| Risk | Probability | Impact | Status | Mitigation |
|------|------------|--------|---------|------------|
| Payments complexity higher than estimated | Medium | High | Monitoring | Spike planned for Week 14 |
| Team C capacity (3 people, 2 on vacation in Week 18) | High | Medium | New | Adjust schedule or borrow resources |
| Performance regression in Auth service | Low | High | Mitigated | Load testing passed ✅ |

---

📈 **Metrics:**

- **Uptime:** 99.95% (target: 99.9%) ✅
- **Auth Service Latency:** P95 150ms (target: <200ms) ✅
- **Incidents:** 0 related to migration ✅
- **Team Satisfaction:** 8/10 (survey last week)

---

🎯 **Decisions Needed:**

1. **Team C Vacation Coverage** (Week 18)
   - Option A: Delay Payments migration by 2 weeks
   - Option B: Borrow 1 engineer from Team D
   - **Recommendation:** Option B (keeps program on track)
   - **Decision by:** Next week's steering committee

---

📅 **Next Week Focus:**
- Complete User Service migration (Pilot 2)
- Conduct go/no-go review for Phase 3
- Begin Payments Service spike (complexity assessment)
- Address Team C vacation coverage

---

**Prepared by:** TPM | **Date:** 2024-03-20
**Next Update:** 2024-03-27
```

## Success Metrics for AI Collaboration

- Programs delivered on time and scope (80%+ success rate)
- All dependencies identified and managed proactively
- Risks tracked with mitigation plans (100% of high-priority risks)
- Stakeholders receive regular status updates
- Cross-team coordination effective (no surprises, blockers resolved quickly)
- Program success criteria met (outcomes achieved, not just output delivered)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Program Management Team
