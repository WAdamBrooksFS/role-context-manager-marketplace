# Post-Mortem: [Incident Title]

<!-- LLM: Post-mortems are blameless. Focus on system failures, not individual mistakes. Help identify root causes and preventive measures. -->

**Date of Incident:** [YYYY-MM-DD HH:MM timezone]
**Duration:** [Hours/minutes]
**Severity:** [Critical / High / Medium / Low]
**Status:** [Draft / Under Review / Published]

**Author:** [Name]
**Reviewers:** [Names]
**Published:** [Date]

---

## Summary

[2-3 sentence summary: What happened, what was the impact, how was it resolved]

---

## Impact

**Customer Impact:**
- [Number] customers affected
- [Number] requests failed
- [Revenue/business impact if applicable]

**Service Impact:**
- **Service(s) Affected:** [List services]
- **Duration:** [Start time] to [End time] = [Duration]
- **Degradation Level:** [Complete outage / Partial outage / Degraded performance]

**Internal Impact:**
- [On-call engineers paged]
- [Engineering time spent]
- [Customer support tickets]

---

## Timeline (All times in [timezone])

| Time | Event |
|------|-------|
| 14:23 | [First symptom detected / alert triggered] |
| 14:25 | [On-call engineer paged] |
| 14:30 | [Investigation began] |
| 14:45 | [Root cause identified] |
| 15:00 | [Fix deployed] |
| 15:15 | [Service recovered] |
| 15:30 | [Confirmed stable] |

---

## Root Cause Analysis

### What Happened

[Detailed description of what went wrong, in plain language]

### Why It Happened

**Immediate Cause:**
[The direct technical cause]

**Contributing Factors:**
1. [Factor 1 that contributed]
2. [Factor 2 that contributed]
3. [Factor 3 that contributed]

**Root Cause:**
[The underlying system or process failure - dig deep with "5 Whys"]

**Example 5 Whys:**
1. **Why did the service crash?** Database connection pool exhausted
2. **Why was the pool exhausted?** Traffic spike from new feature launch
3. **Why didn't we handle the traffic?** No load testing before launch
4. **Why no load testing?** Not included in release checklist
5. **Why not in checklist?** Process gap - no documented requirement

---

## Detection & Response

### How We Detected the Issue
[How did we know something was wrong? Monitoring alert? Customer report?]

### What Worked Well
- [Positive aspect 1 - e.g., "Alert fired within 30 seconds"]
- [Positive aspect 2 - e.g., "Clear runbook helped resolve quickly"]
- [Positive aspect 3 - e.g., "Team coordinated well in incident channel"]

### What Didn't Work
- [Issue 1 - e.g., "Alert didn't specify which service was affected"]
- [Issue 2 - e.g., "Runbook was outdated"]
- [Issue 3 - e.g., "Took 15min to find right person to page"]

---

## Resolution

### How We Fixed It (Short-term)
[What we did to restore service immediately]

### Verification
[How we confirmed the fix worked and service was stable]

---

## Action Items

All action items must have owner and due date.

### Prevent Recurrence (High Priority)

- [ ] **Action 1:** [Specific preventive measure]
  - **Owner:** [Name]
  - **Due:** [Date]
  - **Status:** [Not Started / In Progress / Complete]

- [ ] **Action 2:** [Specific preventive measure]
  - **Owner:** [Name]
  - **Due:** [Date]
  - **Status:** [Status]

### Improve Detection

- [ ] **Action:** [How to detect faster next time]
  - **Owner:** [Name]
  - **Due:** [Date]

### Improve Response

- [ ] **Action:** [How to respond faster next time]
  - **Owner:** [Name]
  - **Due:** [Date]

### Documentation

- [ ] **Action:** Update runbook with lessons learned
  - **Owner:** [Name]
  - **Due:** [Date]

---

## Lessons Learned

### What We Learned
1. [Key lesson 1]
2. [Key lesson 2]
3. [Key lesson 3]

### What We'll Do Differently
1. [Process/system change 1]
2. [Process/system change 2]

---

## Technical Details

### Architecture Diagram
[Diagram showing the system components involved]

### Logs / Evidence
[Links to relevant logs, dashboards, or screenshots]

### Configuration Changes
[Any configuration changes made during or after incident]

---

## Communication

### Internal Communication
- **Incident Channel:** [#incident-2024-03-20]
- **Stakeholders Notified:** [List]

### External Communication
- **Status Page Updated:** [Yes/No, link]
- **Customer Email Sent:** [Yes/No]
- **Public Post-Mortem:** [Yes/No, link if applicable]

---

## Follow-up Review

**Review Date:** [30 days after incident]
**Review Attendees:** [Team]

**Questions to Answer:**
- Have all action items been completed?
- Have preventive measures been effective?
- Any additional insights after 30 days?

---

## Appendix

### Related Incidents
- [Link to similar past incidents]

### References
- [Links to relevant documentation, ADRs, etc.]

---

**Published:** [Date]
**Distribution:** [Engineering team, Leadership, etc.]

<!-- LLM: Post-mortems are blameless. Never assign individual blame. Focus on system improvements, process gaps, and prevention. Help teams learn and improve without fear. -->
