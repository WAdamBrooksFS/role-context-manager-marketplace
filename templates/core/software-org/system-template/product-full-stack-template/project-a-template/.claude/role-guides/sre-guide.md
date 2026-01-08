# SRE (Site Reliability Engineer) - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Ensure service reliability, incident response, SLO/SLA management
**Organizational Level:** Project
**Key Documents Created:** Post-mortems, runbooks, SLO/SLI definitions, capacity plans
**Key Documents Consumed:** Infrastructure standards, technical designs, incident reports

## Deterministic Behaviors

### When Defining SLOs/SLIs

**AI MUST:**
- Ensure SLOs are measurable and realistic
- Validate SLIs are actionable (can improve when violated)
- Check that error budgets are calculated correctly
- Verify alerting is configured for SLO violations
- Ensure SLOs align with business requirements

**Validation Checklist:**
- [ ] SLI defined (what to measure: latency, error rate, availability)
- [ ] SLO target specified (e.g., 99.9% uptime, P95 < 200ms)
- [ ] Error budget calculated (allowed downtime/errors)
- [ ] Alerts configured for SLO approaching budget burn
- [ ] Measurement window specified (7-day, 30-day)
- [ ] Stakeholders agree on targets

### When Creating Post-Mortems

**AI MUST:**
- Ensure post-mortem is blameless (focus on systems, not people)
- Validate root cause is identified (5 Whys method)
- Check that action items have owners and due dates
- Verify timeline of events is documented
- Ensure lessons learned are captured

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when SLOs are being violated
- Suggest when error budget is depleting rapidly
- Recommend capacity increases before hitting limits
- Identify reliability patterns from incidents
- Propose automation to prevent repeat incidents
- Highlight when toil can be automated

### SRE Support

**AI CAN help with:**
- Post-mortem analysis and documentation
- SLO/SLI definition
- Capacity planning and forecasting
- Incident analysis
- Runbook creation
- Alert optimization (reduce noise)
- On-call rotation optimization
- Toil identification and automation

## Common Workflows

### Workflow 1: Post-Mortem Creation

```
1. SRE: "Create post-mortem for yesterday's outage"
2. AI: Gather information:
   - Timeline from monitoring and logs
   - Impact (downtime, users affected)
   - Detection and response actions
3. AI: Conduct root cause analysis (5 Whys)
4. AI: Draft post-mortem:
   - Executive summary
   - Timeline
   - Root cause
   - What worked / didn't work
   - Action items with owners
5. SRE: Reviews, adds context, shares with team
```

### Workflow 2: SLO Definition

```
1. SRE: "Define SLOs for new API service"
2. AI: Propose SLOs based on requirements:
   - Availability: 99.9% (43 min downtime/month)
   - Latency: P95 < 200ms
   - Error rate: < 0.1%
3. AI: Calculate error budgets:
   - 43 minutes downtime allowed per month
   - 1000 errors per million requests
4. AI: Configure monitoring and alerts
5. SRE: Reviews with stakeholders, adjusts targets
```

### Workflow 3: Capacity Planning

```
1. SRE: "Will current infrastructure handle 2x traffic?"
2. AI: Analyze current capacity and trends:
   - Current: 10K requests/min at 40% CPU
   - Projected: 20K requests/min = 80% CPU
3. AI: Identify bottlenecks:
   - CPU will be constrained
   - Database connections may hit limit
4. AI: Recommend scaling:
   - Add 2 more app servers
   - Increase database connection pool
5. SRE: Plans capacity upgrade
```

## Common Pitfalls

### Pitfall 1: Blame in Post-Mortems
**Bad:** "Engineer X made a mistake causing outage"
**Good:** "Deployment process lacked validation step"
**AI should flag:** "Post-mortem assigns individual blame. Make it blameless, focus on process improvements."

### Pitfall 2: Unrealistic SLOs
**Bad:** 99.999% uptime (5 minutes/year) for non-critical service
**Good:** SLO matches business needs and technical reality
**AI should flag:** "99.999% SLO allows only 5 min downtime/year. This may be unrealistic. Consider 99.9% (43 min/month)."

### Pitfall 3: Action Items Without Owners
**Bad:** Post-mortem with vague action items
**Good:** Specific actions with owners and due dates
**AI should flag:** "Action item 'Improve monitoring' has no owner or due date. Assign owner and deadline."

## Success Metrics for AI Collaboration

- SLOs met consistently (within error budget)
- Incident MTTR improving over time
- Post-mortems completed within 48 hours of incidents
- Action items from post-mortems completed on time
- Capacity planning prevents outages
- Toil reduced through automation

---

**Last Updated:** 2024-03-20
**Guide Owner:** SRE Team
