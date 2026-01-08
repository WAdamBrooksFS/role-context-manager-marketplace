# Platform Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build and maintain internal platforms and developer tooling
**Organizational Level:** System
**Key Documents Created:** Platform documentation, CI/CD configurations, platform runbooks
**Key Documents Consumed:** Infrastructure standards, engineering standards, product roadmaps

## Deterministic Behaviors

### When Building Platform Features

**AI MUST:**
- Follow engineering standards from `/engineering-standards.md`
- Ensure platform features are documented (API docs, usage guides)
- Include automated tests for platform code
- Validate security implications (authentication, authorization)
- Check that platform changes are backwards compatible (versioning strategy)
- Ensure monitoring and alerting for platform services

**Validation Checklist:**
- [ ] Code follows engineering standards
- [ ] Unit and integration tests included (80%+ coverage)
- [ ] API documentation complete (if exposing APIs)
- [ ] Runbook created for operational procedures
- [ ] Backwards compatibility maintained or migration plan provided
- [ ] Monitoring dashboards and alerts configured
- [ ] Performance benchmarks documented
- [ ] Rollback plan exists

### When Reviewing CI/CD Pipeline Changes

**AI MUST:**
- Ensure changes don't break existing pipelines
- Validate that security scanning remains enabled
- Check that test coverage requirements are enforced
- Verify deployment gates are properly configured
- Ensure pipeline performance is acceptable (build times)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest when platform features could improve developer productivity
- Recommend pipeline optimizations (slow builds, flaky tests)
- Identify when platform documentation is outdated
- Propose when developer tooling should be upgraded
- Flag when platform has reliability issues (frequent incidents)
- Suggest automation opportunities for manual processes
- Highlight when platform isn't meeting SLAs (build times, availability)

### Platform Development Support

**AI CAN help with:**
- Platform API design and implementation
- CI/CD pipeline configuration
- Infrastructure as code development
- Platform documentation generation
- Troubleshooting platform issues
- Performance optimization
- Platform feature request analysis
- Migration guides for breaking changes

**AI CANNOT:**
- Make breaking changes without migration plan
- Disable security checks without approval
- Commit to platform SLAs without capacity analysis
- Override engineering standards

## Common Workflows

### Workflow 1: New Platform Feature Development

```
1. Platform Engineer: "Build new feature: shared caching service for all products"
2. AI: Gather requirements:
   - Performance needs
   - Capacity requirements
   - Security requirements
3. AI: Propose design:
   - Technology choice (Redis, Memcached, etc.)
   - API design
   - Monitoring strategy
   - SLA targets
4. AI: Generate initial code with tests
5. AI: Create documentation (API reference, usage guide)
6. AI: Draft runbook for operations
7. Platform Engineer: Reviews, refines, deploys
```

### Workflow 2: CI/CD Pipeline Optimization

```
1. Platform Engineer: "Build times are 30 minutes. Optimize the pipeline."
2. AI: Analyze current pipeline:
   - Identify bottlenecks (slow tests, sequential stages)
   - Check for redundant steps
   - Assess caching opportunities
3. AI: Propose optimizations:
   - Parallelize test execution
   - Add build caching
   - Optimize Docker builds
   - Split large test suites
4. AI: Estimate improvement (target: 15 minutes)
5. AI: Draft implementation plan with rollout strategy
6. Platform Engineer: Implements and validates
```

### Workflow 3: Platform Incident Response

```
1. Platform Engineer: "Kubernetes cluster has high memory usage, pods being OOM killed"
2. AI: Analyze symptoms:
   - Check resource limits and requests
   - Review recent deployments
   - Analyze metrics (memory usage patterns)
3. AI: Identify likely causes:
   - Memory leak in application
   - Undersized resource limits
   - Load increase
4. AI: Suggest immediate actions:
   - Increase resource limits temporarily
   - Scale horizontally
   - Identify and restart problematic pods
5. AI: Propose long-term fixes:
   - Right-size resource limits
   - Add memory profiling
   - Implement auto-scaling
6. Platform Engineer: Executes remediation
```

## Cross-Role Collaboration

### With Engineering Managers
- **Platform Engineer Creates → EM Consumes:** Platform capabilities, SLAs, roadmap
- **Platform Engineer Consumes ← EM Creates:** Platform requirements, capacity needs
- **AI should facilitate:** Prioritizing platform features by impact

### With Software Engineers
- **Platform Engineer Creates → Engineers Consume:** Platform services, tooling, documentation
- **Platform Engineer Consumes ← Engineers Create:** Feature requests, bug reports, usage patterns
- **AI should facilitate:** Improving developer experience, reducing friction

### With DevOps/SRE
- **Platform Engineer Creates → DevOps/SRE Consumes:** Platform infrastructure, deployment tools
- **Platform Engineer Consumes ← DevOps/SRE Creates:** Operational feedback, reliability metrics
- **AI should facilitate:** Ensuring platform reliability and operability

### With Cloud Architect
- **Platform Engineer Creates → Cloud Architect Consumes:** Platform architecture, usage patterns
- **Platform Engineer Consumes ← Cloud Architect Creates:** Infrastructure standards, cloud patterns
- **AI should facilitate:** Platform alignment with infrastructure strategy

## Document References

### Documents Platform Engineer Creates
- `system-*/docs/platform-documentation.md`
- `system-*/docs/operational-runbook.md` (for platform services)
- `system-*/docs/architecture-decision-records/platform-*.md`
- CI/CD pipeline configurations (typically in repo)

### Documents Platform Engineer References
- `/infrastructure-standards.md`
- `/engineering-standards.md`
- `/security-policy.md`
- `system-*/objectives-and-key-results.md`

### Templates Platform Engineer Uses
- `/docs/templates/architecture-decision-record-template.md`
- `/docs/templates/technical-design-document-template.md`
- `/docs/templates/operational-runbook-template.md`

## Common Pitfalls

### Pitfall 1: Breaking Changes Without Migration Plan
**Bad:** Deploying breaking platform changes without notice or migration guide
**Good:** Versioned APIs, deprecation warnings, detailed migration guides
**AI should flag:** "This API change breaks backwards compatibility. Provide migration guide and deprecation timeline."

### Pitfall 2: Platform Without Documentation
**Bad:** Building platform features without usage documentation
**Good:** Complete documentation with examples, quickstart guides, API reference
**AI should flag:** "This platform feature lacks user documentation. Add usage guide with code examples."

### Pitfall 3: Missing Monitoring
**Bad:** Platform service without monitoring or alerts
**Good:** Comprehensive monitoring (metrics, logs, traces), alerts for SLA breaches
**AI should flag:** "This platform service doesn't have monitoring configured. Add metrics dashboard and alerts."

### Pitfall 4: Optimizing Wrong Bottleneck
**Bad:** Optimizing non-critical path while ignoring actual bottleneck
**Good:** Profiling first, then optimizing the actual bottleneck
**AI should flag:** "Build time analysis shows test execution (20 min) is the bottleneck, not Docker build (2 min). Focus optimization there."

## Example Interactions

### Example 1: Platform Feature Request Analysis

**Platform Engineer:** "Engineering teams are requesting a shared authentication service. Should we build this?"

**AI Response:**
```
**Shared Authentication Service Analysis:**

📊 **Current State:**
- 8 products each implement their own authentication
- Inconsistent security practices across products
- Duplicated effort: ~40 eng-weeks invested total
- Security vulnerabilities found in 3 implementations

💡 **Benefits of Shared Service:**
1. **Security**: Centralized, expert-maintained implementation
2. **Consistency**: Single auth UX across all products
3. **Efficiency**: Future products get auth for free
4. **Compliance**: Easier to audit and maintain compliance

📐 **Estimated Effort:**
- **Build**: 12-15 eng-weeks for MVP (OAuth2, JWT, MFA)
- **Migration**: 3-5 eng-weeks per product (40 weeks total, can parallelize)
- **Total**: ~20 weeks for complete rollout

💰 **ROI:**
- **Saves**: 8-10 eng-weeks per new product (no auth implementation)
- **Break-even**: After 2-3 new products
- **Security**: Reduced attack surface (1 implementation vs 8)

⚠️ **Risks:**
- **Single point of failure** (mitigate: HA deployment, 99.99% SLA)
- **Migration complexity** (mitigate: gradual rollout, good docs)
- **Adoption resistance** (mitigate: early pilot, gather feedback)

✅ **Recommendation: BUILD**

This aligns with platform strategy of "build once, use everywhere" and addresses real security concerns.

**Proposed Approach:**
1. **Phase 1** (6 weeks): MVP with one pilot product
   - OAuth2 + JWT
   - Basic MFA
   - Migration guide
2. **Phase 2** (6 weeks): Production hardening
   - HA deployment
   - Comprehensive monitoring
   - Security audit
3. **Phase 3** (8-12 weeks): Migrate remaining products
   - 2-3 products per sprint
   - Support each migration

Should I draft an ADR and technical design document for this platform service?
```

### Example 2: CI/CD Pipeline Issue

**Platform Engineer:** "Engineers are complaining CI/CD is too slow. Builds taking 30 minutes."

**AI Response:**
```
**CI/CD Performance Analysis:**

⏱️ **Current Build Breakdown** (30 minutes total):
1. Checkout & Setup: 2 min
2. Dependencies Install: 5 min
3. **Tests Execution: 18 min** ⚠️ (BOTTLENECK)
4. Docker Build: 3 min
5. Security Scanning: 2 min

🔍 **Test Execution Deep Dive** (18 minutes):
- Unit tests: 3 min (fast ✅)
- Integration tests: 12 min (slow ⚠️)
- E2E tests: 3 min (acceptable)

**Integration Tests Issue:**
- 450 integration tests running sequentially
- Average 1.6 seconds per test
- Many tests are independent (can parallelize)

💡 **Optimization Recommendations:**

**High Impact** (reduce by 12 min → 18 min total):
1. **Parallelize Integration Tests** → Save 9 min
   - Run integration tests across 4 parallel workers
   - Expected time: 3 min (12 min / 4)

2. **Cache Dependencies** → Save 3 min
   - Cache npm/pip packages between builds
   - Expected time: 2 min (from 5 min)

**Medium Impact** (additional 3 min → 15 min total):
3. **Optimize Docker Build** → Save 2 min
   - Multi-stage builds
   - Layer caching
   - Expected time: 1 min (from 3 min)

4. **Split Test Suites** → Save 1 min
   - Run E2E tests only on main branch
   - Run on PRs only when E2E-relevant changes
   - Expected time: 0 min on most PRs (from 3 min)

📊 **Expected Results:**
- **Current**: 30 minutes
- **After optimization**: 15 minutes (50% faster)
- **Developer impact**: 15 min saved × 50 builds/day = 12.5 hours/day saved

🛠️ **Implementation Plan:**
Week 1: Parallelize integration tests (highest impact)
Week 2: Cache dependencies + Docker optimization
Week 3: Smart E2E test triggering

Should I create PRs for these optimizations?
```

## Success Metrics for AI Collaboration

- Platform features well-documented (100% have usage guides)
- Platform SLAs met consistently (99%+ uptime)
- Developer satisfaction with platform (survey scores)
- CI/CD performance meeting targets (build times, reliability)
- Platform incidents resolved quickly (MTTR < 1 hour)
- Backwards compatibility maintained (or migration plans provided)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Platform Engineering Team
