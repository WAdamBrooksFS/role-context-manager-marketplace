# Incident Response Process

<!-- LLM: In an incident, speed matters. Help teams follow this process efficiently. Escalate appropriately. Focus on resolution first, root cause later. -->

**Owner:** SRE Team + Security Team
**Last Updated:** [Date]

## Purpose

This document defines how we respond to production incidents, from detection to resolution to post-mortem.

---

## Incident Severity Levels

| Severity | Definition | Examples | Response Time | Notification |
|----------|------------|----------|---------------|--------------|
| **P0 - Critical** | Complete outage, data loss, security breach | Service down, payment processing broken, data breach | Immediate | Page on-call, notify leadership |
| **P1 - High** | Major feature broken, significant degradation | Login broken for subset of users, database slow | < 15min | Page on-call |
| **P2 - Medium** | Minor feature broken, workaround exists | UI bug, non-critical API errors | < 1 hour | Notify on-call (no page) |
| **P3 - Low** | Cosmetic issue, minimal impact | Typo, minor styling issue | Next business day | Create ticket |

---

## Incident Lifecycle

### 1. Detection

**How incidents are detected:**
- Automated monitoring alerts
- Customer reports
- Internal team discovery

**First Responder:**
- On-call engineer receives alert/report
- Creates incident in tracking system
- Posts in `#incidents` Slack channel

### 2. Triage (< 5 minutes)

**Assess severity:**
- How many customers affected?
- What functionality is broken?
- Is data at risk?
- Is this a security issue?

**Assign severity (P0-P3)**

**Create incident channel:**
```
#incident-YYYY-MM-DD-[short-description]
Example: #incident-2024-03-20-api-outage
```

### 3. Assemble Team

**P0/P1 Incidents:**
- **Incident Commander (IC):** On-call engineer (or delegate)
- **Technical Lead:** Engineer investigating/fixing
- **Communications Lead:** Updates stakeholders
- **Engineering Manager:** (for P0)
- **Security Team:** (if security-related)

**Roles:**

**Incident Commander (IC):**
- Coordinates response
- Makes decisions
- Manages escalations
- NOT responsible for fixing (delegates that)

**Technical Lead:**
- Investigates root cause
- Implements fix
- Reports findings to IC

**Communications Lead:**
- Updates status page
- Posts updates in incident channel every 15-30min
- Notifies customers if needed
- Coordinates with support team

### 4. Investigate & Mitigate

**Priority: Stop the bleeding first**

**Immediate Actions:**
1. Check service health dashboards
2. Review recent changes (deployments, config changes)
3. Check dependencies (databases, external APIs)
4. Review logs and error messages

**Mitigation Strategies:**
- **Rollback** recent deployment (if bad deploy)
- **Scale up** resources (if capacity issue)
- **Disable** problematic feature (if feature causing issue)
- **Failover** to backup system
- **Circuit breaker** to failing dependency

**Don't:**
- Don't try experimental fixes in production
- Don't make changes without IC approval
- Don't investigate root cause before mitigating impact

### 5. Communicate

**Internal Communication:**

**Every 15-30 minutes in incident channel:**
```
**Update [Time]**
Status: [Investigating / Mitigating / Resolved]
Impact: [What's broken]
Action: [What we're doing]
ETA: [When we expect resolution, or "unknown"]
```

**External Communication:**

**Status Page Updates:**
- **Immediately:** Post that we're investigating
- **Every 30min:** Update with progress
- **Resolution:** Post that issue is resolved, monitoring
- **Post-mortem:** Link to public post-mortem (if applicable)

**Customer Emails (for P0/P1):**
- Send within 1 hour of incident start
- Include: what happened, impact, status, ETA
- Follow up when resolved

### 6. Resolve

**Resolution Checklist:**
- [ ] Issue fixed
- [ ] Service health metrics returned to normal
- [ ] No error alerts firing
- [ ] Monitored for 30 minutes (stable)
- [ ] Customer impact verified resolved

**Post-Resolution:**
- Update status page: "Resolved"
- Post in incident channel: Incident closed
- Thank everyone involved
- Schedule post-mortem (within 48 hours)

### 7. Post-Mortem

**Required for:**
- All P0 incidents
- All P1 incidents
- Any incident with customer impact
- Any incident revealing process gaps

**Timeline:**
- Draft within 24 hours
- Review with team within 48 hours
- Publish within 72 hours

**See:** `/docs/templates/post-mortem-template.md`

---

## Communication Templates

### Initial Announcement (Internal)
```
@here Incident declared: [Title]
Severity: [P0/P1/P2]
Impact: [What's broken, how many customers]
Incident Channel: #incident-YYYY-MM-DD-[name]
IC: @[Name]
```

### Status Page Update (External)
```
**Investigating**: We are investigating reports of [issue description].
Some customers may be experiencing [impact]. We will provide updates
as we learn more.
```

### Resolution Announcement (External)
```
**Resolved**: The issue affecting [feature/service] has been resolved
as of [time]. All systems are operating normally. We apologize for
any inconvenience. A detailed post-mortem will be published within
48 hours.
```

---

## Escalation

### When to Escalate

**To Engineering Manager:**
- P0 incidents (immediately)
- P1 lasting > 1 hour
- Unclear how to proceed
- Need additional resources

**To Security Team:**
- Any suspected security breach
- Data exposure
- Unauthorized access
- DDoS attack

**To Leadership (CTO/CEO):**
- Major customer impact
- Data breach
- Media attention likely
- Legal implications

### Escalation Contacts

**On-Call Escalation:**
1. Primary on-call: [PagerDuty rotation]
2. Backup on-call: [PagerDuty rotation]
3. Engineering Manager: [Contact]
4. CTO: [Contact]

**Security Incidents:**
- Security Team: security@company.com
- CISO: [Contact]

---

## Blameless Culture

**Our Philosophy:**
- Focus on systems and processes, not people
- Assume everyone did their best with information available
- Learn from mistakes, don't punish them
- Encourage reporting issues early

**In Post-Mortems:**
- ✅ "The deployment process lacked adequate testing"
- ❌ "Engineer X didn't test properly"

---

## Incident Metrics

**Track and Review Quarterly:**
- Number of incidents by severity
- Mean Time to Detect (MTTD)
- Mean Time to Resolve (MTTR)
- Repeat incidents (same root cause)
- Customer-impacting incidents

**Goals:**
- MTTD: < 5 minutes
- MTTR (P0): < 1 hour
- MTTR (P1): < 4 hours
- Repeat incidents: 0

---

## Tools

**Incident Management:** [PagerDuty / Opsgenie]
**Status Page:** [Statuspage.io / Custom]
**Monitoring:** [Datadog / New Relic / CloudWatch]
**Logs:** [ELK / Splunk / CloudWatch Logs]
**Communication:** Slack #incidents channel

---

**Last Updated:** [Date]
**Owner:** [SRE Team Lead]

<!-- LLM: During incidents, prioritize speed of resolution over root cause analysis. Help teams follow this process efficiently. Remind about blameless culture. -->
