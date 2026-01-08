# Technical Design Document (TDD): [Feature Name]

<!-- LLM: TDDs provide detailed technical design before implementation. Help engineers think through architecture, data models, APIs, and edge cases. Validate designs against engineering standards and best practices. -->

**Status:** [Draft / In Review / Approved / Implemented]
**Author:** [Engineering Lead Name]
**Created:** [Date]
**Last Updated:** [Date]

**Related Documents:**
- PRD: [Link to product requirements]
- RFC: [Link to RFC if this implements one]
- ADRs: [Links to relevant architecture decisions]

---

## Overview

### Problem Statement
[What technical problem are we solving? Reference PRD for business context.]

### Proposed Solution
[High-level technical approach in 2-3 sentences]

### Goals
- [Technical goal 1]
- [Technical goal 2]

### Non-Goals
- [Explicitly NOT solving this]

---

## System Architecture

### High-Level Design

[Diagram showing major components and their interactions]

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ HTTPS
┌──────▼──────┐
│     API     │
│   Gateway   │
└──────┬──────┘
       │
┌──────▼──────────┐
│   Service Layer │
│  (Business Logic)│
└──────┬──────────┘
       │
┌──────▼──────┐
│  Database   │
└─────────────┘
```

### Component Descriptions

#### Component 1: [Name]
**Responsibility:** [What this component does]
**Technology:** [Language/framework]
**Interfaces:** [APIs it exposes]
**Dependencies:** [What it depends on]

#### Component 2: [Name]
[Follow same pattern]

---

## API Design

### New Endpoints

#### POST /api/v1/resource
**Description:** [What this endpoint does]

**Request:**
```json
{
  "field1": "string",
  "field2": 123
}
```

**Response (Success - 200):**
```json
{
  "id": "uuid",
  "field1": "string",
  "created_at": "2024-03-20T10:00:00Z"
}
```

**Response (Error - 400):**
```json
{
  "error": "Invalid input",
  "details": "field1 is required"
}
```

**Authentication:** Required (Bearer token)
**Rate Limiting:** 100 requests/minute per user
**Validation:** [Validation rules]

### Modified Endpoints
[List any changes to existing APIs]

### Breaking Changes
[List any breaking changes with migration path]

---

## Data Model

### Database Schema

#### New Tables

**Table: `resources`**
```sql
CREATE TABLE resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

  INDEX idx_user_id (user_id),
  INDEX idx_status (status)
);
```

**Rationale:**
- UUID for IDs (distributed system friendly)
- Indexes on foreign keys and frequently queried fields
- Timestamps for auditing

#### Modified Tables
[Describe changes to existing tables, include migration scripts]

### Data Flow

```
User Request → API Validation → Business Logic → Database Write → Response
```

[Describe data transformations at each step]

---

## Security Considerations

### Authentication & Authorization
- [How authentication works]
- [Authorization rules]

### Data Protection
- [Encryption approach]
- [PII handling per /data-governance.md]

### Input Validation
- [Validation rules]
- [Protection against injection attacks]

### Rate Limiting
- [Rate limiting strategy]

---

## Performance

### Expected Load
- [Requests per second]
- [Data volume]
- [Concurrent users]

### Performance Targets
- API response time: < [X]ms at p95
- Database query time: < [Y]ms
- Throughput: [Z] requests/second

### Optimization Strategies
- [Caching strategy]
- [Database indexing]
- [Query optimization]
- [Horizontal scaling approach]

### Load Testing Plan
[How we'll validate performance]

---

## Scalability

### Horizontal Scaling
[How this design scales out]

### Database Scaling
[Sharding strategy, read replicas, etc.]

### Caching Strategy
- **What to cache:** [Data that's expensive to compute]
- **Cache TTL:** [Time to live]
- **Cache invalidation:** [When/how to invalidate]

---

## Monitoring & Observability

### Metrics to Track
- Request rate
- Error rate
- Latency (p50, p95, p99)
- Database query performance
- Cache hit rate

### Logging
- [What to log]
- [Log level guidance]
- [No PII in logs per /data-governance.md]

### Alerts
- Error rate > 1% → Page on-call
- Latency p95 > 500ms → Warning alert
- Database connection pool exhausted → Page on-call

### Dashboards
[What dashboards will be created]

---

## Error Handling

### Error Scenarios

#### Scenario 1: [Error Name]
**Trigger:** [What causes this error]
**User Impact:** [How user experiences it]
**Handling:** [How system responds]
**Recovery:** [How to recover]

#### Scenario 2: Database Unavailable
**Trigger:** Database connection fails
**User Impact:** API returns 503 Service Unavailable
**Handling:** Circuit breaker pattern, fail fast
**Recovery:** Automatic retry with exponential backoff, health check

---

## Testing Strategy

### Unit Tests
- Test all business logic functions
- Mock external dependencies
- Target: 80%+ coverage

### Integration Tests
- Test API endpoints end-to-end
- Use test database
- Cover happy path + error scenarios

### Performance Tests
- Load test with [N]x expected traffic
- Validate response times meet targets

### Security Tests
- Run SAST/DAST scans
- Test authentication/authorization
- Validate input sanitization

---

## Deployment Plan

### Phase 1: Development & Testing
1. Implement core functionality
2. Write tests
3. Deploy to dev environment
4. Internal testing

### Phase 2: Staging
1. Deploy to staging
2. QA testing
3. Performance testing
4. Security review

### Phase 3: Production Rollout
1. Deploy with feature flag (disabled)
2. Enable for internal users (beta)
3. Canary rollout (10% → 50% → 100%)
4. Monitor metrics closely

### Rollback Plan
- Feature flag: Instant rollback (disable flag)
- Database changes: Backward compatible migrations
- API changes: Maintain v1 compatibility

---

## Migration & Backward Compatibility

### Data Migration
[If migrating existing data]

**Steps:**
1. [Migration step 1]
2. [Migration step 2]

**Rollback:**
[How to revert migration]

### API Versioning
[How this affects existing API clients]

---

## Dependencies

### Upstream Dependencies (Must exist first)
- [Service/system this depends on]

### Downstream Impact (Who depends on this)
- [Systems that will be affected]

### Third-Party Services
- [External services used]
- [SLAs and failover plans]

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Database performance degradation | Medium | High | Index optimization, caching, load testing |
| Third-party API downtime | Low | Medium | Circuit breaker, fallback behavior |
| Complex migration fails | Low | High | Thorough testing, rollback plan, gradual rollout |

---

## Open Questions

- [ ] **Question 1:** [Unresolved technical question]
  - **Owner:** [Who will answer]
  - **Due:** [Date]

---

## Timeline

| Milestone | Date | Owner |
|-----------|------|-------|
| Design approved | [Date] | Eng Lead |
| Implementation complete | [Date] | Team |
| QA complete | [Date] | QA |
| Production deploy | [Date] | DevOps |

---

## Approval

**Engineering Lead:** [Name] - [Date]
**Architect:** [Name] - [Date]
**Security Review:** [Name] - [Date]

---

<!-- LLM: TDDs should be detailed enough to implement from. Help engineers think through edge cases, performance, security, and operations. Suggest missing considerations. Validate against company standards. -->
