# Agile Practices

<!-- LLM: Help teams follow consistent agile practices. When planning or reviewing sprints, validate against these standards. Suggest improvements based on agile best practices. -->

**Status:** Living | **Update Frequency:** Semi-annually
**Primary Roles:** Scrum Masters, Agile Coaches, Engineering Managers, All Teams
**Related Documents:** `/engineering-standards.md`

## Purpose

This document defines our agile methodology, ceremonies, and best practices across all engineering teams.

---

## Agile Framework: Scrum

We use Scrum as our primary agile framework with 2-week sprints.

---

## Sprint Structure

**Sprint Duration:** 2 weeks
**Sprint Start:** Monday morning
**Sprint End:** Friday afternoon (second week)

### Sprint Planning (Monday, 2 hours)
**Attendees:** Team, Product Manager, Scrum Master
**Agenda:**
1. Review sprint goal (what we want to achieve)
2. Review prioritized backlog
3. Team commits to stories for sprint
4. Break down stories into tasks
5. Estimate and assign work

**Output:** Sprint backlog with committed stories

### Daily Standup (Every day, 15 minutes)
**Attendees:** Team, Scrum Master (optional: PM)
**Format:** Each person answers:
1. What did I complete yesterday?
2. What am I working on today?
3. Are there any blockers?

**Rules:**
- Keep it to 15 minutes
- Take detailed discussions offline
- Focus on coordination, not status reports

### Sprint Review / Demo (Friday, 1 hour)
**Attendees:** Team, stakeholders, PM
**Agenda:**
1. Demo completed features
2. Gather feedback
3. Review sprint metrics (velocity, burn-down)

**Output:** Stakeholder feedback, updated backlog

### Sprint Retrospective (Friday, 1 hour)
**Attendees:** Team, Scrum Master
**Agenda:**
1. What went well?
2. What could be improved?
3. Action items for next sprint

**Rules:**
- Blameless environment
- Focus on process, not people
- Commit to 1-3 action items (not 10)

### Backlog Refinement (Mid-sprint, 1 hour)
**Attendees:** Team, PM, Scrum Master
**Agenda:**
1. Review upcoming stories
2. Clarify acceptance criteria
3. Estimate story points
4. Identify dependencies

**Output:** Refined backlog ready for next sprint planning

---

## Story Points & Estimation

**Modified Fibonacci Scale:** 1, 2, 3, 5, 8, 13, 21

**Guidelines:**
- 1 point = Simple change (few hours)
- 3 points = Standard feature (1-2 days)
- 5 points = Complex feature (3-4 days)
- 8+ points = Too large, break it down

**Estimation Technique:** Planning Poker
**Reference Story:** Establish a "3-point story" as baseline for team calibration

---

## Definition of Ready (DoR)

A user story is ready for sprint when:
- [ ] Clear acceptance criteria
- [ ] Estimated by team
- [ ] Dependencies identified
- [ ] Design mockups complete (if UI work)
- [ ] No open questions
- [ ] Sized appropriately (< 8 points)

---

## Definition of Done (DoD)

A user story is done when:
- [ ] Code complete and peer reviewed
- [ ] Tests written and passing (unit + integration)
- [ ] Acceptance criteria met
- [ ] Documentation updated
- [ ] Deployed to staging
- [ ] QA sign-off (if required)
- [ ] Product Manager sign-off
- [ ] No critical/high bugs

---

## Velocity & Capacity

**Velocity:** Average story points completed per sprint (rolling 3-sprint average)

**Capacity Planning:**
- Assume 80% capacity (20% for meetings, support, unplanned work)
- Account for PTO and holidays
- New team member = 50% capacity first sprint

---

## Sprint Goals

Every sprint should have a clear goal:
- ✅ Good: "Complete user authentication and enable beta signups"
- ❌ Bad: "Work on stuff in the backlog"

Sprint goal helps with prioritization and focus.

---

## Handling Changes Mid-Sprint

**Emergency Work (P0):**
- Allowed, but document impact on sprint commitment
- Discuss with PM and team

**New Requirements:**
- Add to backlog, prioritize for next sprint
- Do NOT add to current sprint (protects team commitment)

**Scope Changes:**
- If story is bigger than estimated, discuss with PM
- Options: reduce scope, move to next sprint, add resources

---

## Metrics & Continuous Improvement

**Track:**
- Velocity (story points per sprint)
- Sprint commitment success rate (% of committed stories completed)
- Cycle time (time from start to done)
- Defect escape rate (bugs found in production)

**Review Quarterly:**
- Are we improving velocity?
- Are we meeting commitments?
- Are retrospective action items effective?

---

## Remote/Distributed Teams

**Best Practices:**
- Use video for all ceremonies
- Async updates in Slack between standups
- Clear documentation (don't rely on hallway conversations)
- Overlap hours for core collaboration time

---

**Last Updated:** [Date]
**Owner:** [Agile Coach / VP of Engineering]

<!-- LLM: Help teams follow these agile practices. Suggest when ceremonies are missing or not effective. Recommend improvements based on agile principles. -->
