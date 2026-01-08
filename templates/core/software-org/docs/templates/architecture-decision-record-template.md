# ADR [Number]: [Short Decision Title]

<!-- LLM: ADRs document decisions that are already made (past tense). They capture WHY a decision was made for future reference. Help ensure ADRs answer: What was decided? Why? What alternatives were considered? What are the consequences? ADRs are immutable historical records - never edit after creation (create new ADR to supersede). -->

**Status:** [Proposed / Accepted / Deprecated / Superseded]
**Date:** [YYYY-MM-DD]
**Decision Makers:** [Name 1], [Name 2]
**Stakeholders:** [Name 3], [Name 4]

**Supersedes:** [Link to previous ADR if applicable]
**Superseded by:** [Link to newer ADR if this is deprecated]

---

## Context

[Describe the situation, problem, or opportunity. What forces are at play? What constraints exist?]

**Key Context:**
- [Context factor 1]
- [Context factor 2]
- [Context factor 3]

<!-- Example:
Our monolithic Ruby on Rails application is becoming difficult to scale and maintain:
- Single deployment means any change requires full regression testing
- Performance bottlenecks in one feature affect entire application
- Team size growing (30 → 60 engineers), coordination overhead increasing
- Onboarding new engineers takes 4+ weeks due to codebase complexity

**Key Context:**
- Current app: 500K lines of Ruby, 8-year-old codebase
- Traffic: 10M requests/day, growing 20% monthly
- Team: 60 engineers across 8 product teams
- Tech debt: 3 major versions behind on Rails
-->

---

## Decision

[State the decision clearly and concisely. Use present tense as if the decision is now in effect.]

We will [decision statement].

<!-- Example:
We will decompose our monolithic Ruby on Rails application into microservices, starting with the highest-traffic features (checkout, search, recommendations). Services will communicate via RESTful APIs and message queues. The monolith will remain the system of record initially, with gradual migration over 18 months.
-->

---

## Rationale

[Explain WHY this decision was made. What factors led to this choice?]

**Reasons for this decision:**
- [Reason 1]
- [Reason 2]
- [Reason 3]

<!-- Example:
**Reasons for this decision:**
- **Scalability**: High-traffic features (checkout, search) need independent scaling
- **Team Autonomy**: Microservices allow teams to deploy independently, reducing coordination overhead
- **Technology Flexibility**: New services can use languages better suited to their domain (Go for performance-critical services)
- **Failure Isolation**: Bug in one service doesn't bring down entire platform
- **Incremental Migration**: Can migrate gradually over 18 months, reducing risk compared to "big bang" rewrite
-->

---

## Alternatives Considered

### Alternative 1: [Alternative Name]

**Description:** [Brief description of alternative]

**Pros:**
- [Pro 1]
- [Pro 2]

**Cons:**
- [Con 1]
- [Con 2]

**Why not chosen:**
[Brief explanation]

<!-- Example:
### Alternative 1: Continue with Monolith, Optimize

**Description:** Keep monolith, invest in performance optimization, modularize codebase internally (but keep single deployment unit)

**Pros:**
- Lower short-term cost and risk
- No distributed systems complexity
- Team knows Rails well

**Cons:**
- Doesn't address scaling bottlenecks (single server)
- Doesn't reduce deployment risk (all-or-nothing deploys)
- Doesn't provide team autonomy (still coordinated releases)
- Tech debt continues to grow

**Why not chosen:**
Addresses symptoms but not root causes. Growth projections indicate we'll hit scaling limits in 6-9 months.
-->

### Alternative 2: [Alternative Name]
[Follow same pattern]

### Alternative 3: [Alternative Name]
[Follow same pattern]

---

## Consequences

### Positive Consequences
- [Positive impact 1]
- [Positive impact 2]
- [Positive impact 3]

### Negative Consequences
- [Negative impact 1]
- [Negative impact 2]
- [Negative impact 3]

### Neutral Consequences
- [Impact that is neither clearly positive nor negative]

<!-- Example:
### Positive Consequences
- **Independent Scaling**: Can scale checkout service 10x while keeping other services unchanged
- **Faster Deployments**: Teams deploy services independently, increasing deployment frequency from 2x/week to 10x/day
- **Technology Choices**: Can choose best language/framework per service (Go for performance, Python for ML)
- **Failure Isolation**: Search service bug doesn't crash checkout

### Negative Consequences
- **Increased Complexity**: Distributed systems are harder to reason about, debug, and monitor
- **Infrastructure Costs**: Running 15 services vs. 1 monolith increases infrastructure cost by ~40%
- **Learning Curve**: Team needs to learn microservices patterns, distributed tracing, service mesh
- **Migration Effort**: 18 months of migration work, diverting from new features

### Neutral Consequences
- **Testing Strategy Changes**: Need new integration testing approaches for distributed system
- **Monitoring Requirements**: Need distributed tracing, service mesh observability
- **Deployment Pipeline**: CI/CD needs to support independent service deploys
-->

---

## Implementation Notes

### Immediate Next Steps
1. [Action item 1] - [Owner] - [Deadline]
2. [Action item 2] - [Owner] - [Deadline]
3. [Action item 3] - [Owner] - [Deadline]

### Long-term Plan
[Brief overview of implementation timeline]

<!-- Example:
### Immediate Next Steps
1. Create RFC for microservices architecture - Tech Lead - Week 1
2. Choose first service to extract (recommend: checkout) - Architecture team - Week 2
3. Set up service template and CI/CD pipeline - DevOps team - Week 3
4. Implement distributed tracing - Infrastructure team - Week 4

### Long-term Plan
- Months 1-3: Extract checkout service, prove pattern
- Months 4-6: Extract search and recommendations services
- Months 7-12: Extract remaining high-value services
- Months 13-18: Migrate remaining features, retire monolith
-->

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| [Risk 1] | [How we'll address it] |
| [Risk 2] | [How we'll address it] |

<!-- Example:
| Risk | Mitigation |
|------|------------|
| Distributed system too complex for team | Invest in training, start with single service, hire experienced engineers |
| Data consistency issues across services | Use event sourcing, implement compensating transactions |
| Performance degradation from network calls | Implement caching, optimize service boundaries, use async communication |
| Migration takes longer than 18 months | Prioritize highest-value services first, monolith can coexist indefinitely if needed |
-->

---

## Compliance and Security Implications

[Any compliance or security considerations arising from this decision]

<!-- Example:
- Each microservice needs independent security review
- Service-to-service communication must be encrypted (TLS)
- Need distributed audit logging across services (compliance requirement)
- PII handling needs careful design in service boundaries
-->

---

## Measurement and Review

**Success Metrics:**
- [Metric 1]: Target [X]
- [Metric 2]: Target [Y]

**Review Date:** [When will we revisit this decision]

**Review Criteria:** [What would cause us to reconsider]

<!-- Example:
**Success Metrics:**
- Deploy frequency: 2x/week → 10x/day within 6 months
- P95 latency: <500ms for all services
- Cost per request: Not to exceed 1.5x current cost
- Team velocity: Maintain or increase (measure story points/sprint)

**Review Date:** 12 months from implementation start

**Review Criteria:**
- If costs exceed 2x projections, reconsider approach
- If team velocity drops >20%, pause migration
- If customer-impacting incidents increase >50%, reassess
-->

---

## References

- [Related RFC or design doc]
- [External article or resource]
- [Discussion thread or meeting notes]

<!-- Example:
- RFC-042: Microservices Migration Plan
- Martin Fowler's Microservices Guide: https://martinfowler.com/microservices/
- Architecture Review Meeting Notes: 2024-03-15
-->

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| [YYYY-MM-DD] | Initial creation | [Name] |
| [YYYY-MM-DD] | Status changed to Accepted | [Name] |

<!-- Example:
| Date | Change | Author |
|------|--------|--------|
| 2024-03-20 | Initial creation | Marcus Rodriguez |
| 2024-03-25 | Status changed to Accepted after architecture review | CTO |
| 2025-09-15 | Status changed to Superseded by ADR-089 (serverless migration) | CTO |
-->

---

<!-- LLM: ADRs are historical records - they capture decisions at a point in time. They should NEVER be edited to change the decision itself (only status updates or minor clarifications). If a decision changes, create a new ADR that supersedes this one. Help ensure ADRs clearly document WHY decisions were made - this context is invaluable for future engineers. -->
