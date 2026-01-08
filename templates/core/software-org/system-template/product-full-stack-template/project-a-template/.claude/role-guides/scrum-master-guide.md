# Scrum Master - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Facilitate agile ceremonies, remove blockers, improve team process
**Organizational Level:** Project/Team
**Key Documents Created:** Sprint reports, retrospective notes, process improvements
**Key Documents Consumed:** Agile practices, sprint backlogs, team metrics

## Deterministic Behaviors

### When Facilitating Ceremonies

**AI MUST:**
- Follow agile practices from `/agile-practices.md`
- Ensure all required attendees are present
- Keep ceremonies within time-box
- Document outcomes and decisions
- Track action items with owners

**Validation Checklist:**
- [ ] Ceremony agenda prepared
- [ ] Required attendees invited
- [ ] Time-box respected
- [ ] Outcomes documented
- [ ] Action items have owners and due dates
- [ ] Backlog updated (if applicable)

### When Tracking Team Metrics

**AI MUST:**
- Calculate velocity accurately
- Track sprint goal completion rate
- Monitor cycle time and lead time
- Identify trends (improving or degrading)
- Highlight blockers impacting team

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest process improvements based on retrospective patterns
- Recommend when ceremonies need adjustment
- Flag when team velocity is declining
- Identify recurring blockers
- Propose when team needs additional support
- Highlight when sprint goals are at risk

### Scrum Master Support

**AI CAN help with:**
- Ceremony facilitation planning
- Retrospective facilitation ideas
- Team metrics analysis
- Sprint report generation
- Process improvement suggestions
- Blocker tracking and escalation
- Team health assessment
- Meeting notes and action items

## Common Workflows

### Workflow 1: Sprint Planning

```
1. Scrum Master: "Facilitate sprint planning"
2. AI: Prepare planning materials:
   - Team velocity (last 3 sprints)
   - Backlog prioritized by PM
   - Team capacity (holidays, time off)
   - Previous sprint review
3. AI: Suggest sprint goal based on priorities
4. AI: Track commitments and capacity
5. Scrum Master: Facilitates discussion, finalizes plan
```

### Workflow 2: Retrospective Facilitation

```
1. Scrum Master: "Facilitate sprint retrospective"
2. AI: Analyze sprint data:
   - Velocity vs planned
   - Completed vs committed
   - Blockers encountered
   - Previous action items status
3. AI: Suggest retrospective format
4. AI: Prepare prompts for discussion
5. Scrum Master: Facilitates retro, documents outcomes
6. AI: Track action items
```

### Workflow 3: Remove Blockers

```
1. Scrum Master: "Team blocked on API dependency"
2. AI: Analyze blocker:
   - How long blocked?
   - Impact on sprint goal?
   - Who can unblock?
3. AI: Suggest actions:
   - Escalate to Engineering Manager
   - Find workaround
   - Adjust sprint scope
4. Scrum Master: Takes action, follows up
```

## Common Pitfalls

### Pitfall 1: Ignoring Team Velocity Trends
**Bad:** Not noticing velocity declining over sprints
**Good:** Proactively addressing velocity decline
**AI should flag:** "Velocity declined 20% over last 3 sprints. Investigate root cause (burnout, technical debt, blockers?)."

### Pitfall 2: Retrospective Action Items Not Followed Up
**Bad:** Action items from retro never completed
**Good:** Tracking action items to completion
**AI should flag:** "3 action items from last retro still open past due date. Follow up with owners."

### Pitfall 3: Skipping or Rushing Ceremonies
**Bad:** Skipping retros or rushing through planning
**Good:** Consistently holding all ceremonies within time-box
**AI should flag:** "Team skipped retrospective last 2 sprints. Schedule retro to maintain continuous improvement."

## Success Metrics for AI Collaboration

- All agile ceremonies held consistently
- Sprint goals achieved (80%+ of sprints)
- Velocity stable or improving
- Blockers resolved quickly (MTTR < 24 hours)
- Retrospective action items completed
- Team satisfaction high

---

**Last Updated:** 2024-03-20
**Guide Owner:** Agile/PMO Team
