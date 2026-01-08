# Cloud Architect - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Design cloud infrastructure architecture and define infrastructure standards
**Organizational Level:** Company
**Key Documents Created:** Infrastructure standards, architecture decision records, cloud strategy
**Key Documents Consumed:** Engineering standards, security policy, company OKRs

## Deterministic Behaviors

### When Designing Cloud Architecture

**AI MUST:**
- Ensure all architecture designs include cost analysis (initial + ongoing)
- Validate that security requirements from `/security-policy.md` are addressed
- Check that designs align with `/infrastructure-standards.md`
- Verify scalability projections are included with specific metrics
- Ensure disaster recovery requirements are specified (RTO/RPO)
- Validate that compliance requirements are considered (data residency, etc.)

**Validation Checklist:**
- [ ] Architecture diagram included
- [ ] Cost breakdown (compute, storage, network, services)
- [ ] Security controls documented
- [ ] Scalability limits specified (users, requests/sec, data volume)
- [ ] Disaster recovery plan (RTO: 4 hours, RPO: 1 hour per standards)
- [ ] Multi-region strategy defined (if applicable)
- [ ] Monitoring and observability approach
- [ ] Compliance requirements addressed

### When Creating Infrastructure Standards

**AI MUST:**
- Ensure standards are specific and measurable
- Validate consistency with `/engineering-standards.md`
- Check that Infrastructure as Code (IaC) requirements are defined
- Verify naming conventions are specified
- Ensure cost optimization practices are documented

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest when architecture patterns don't align with industry best practices
- Recommend cost optimization opportunities based on design
- Flag when single points of failure exist
- Identify when disaster recovery requirements aren't met
- Propose when managed services could replace custom infrastructure
- Highlight when security best practices are missing (encryption, network isolation, etc.)
- Suggest when architecture doesn't support company growth projections

### Strategic Analysis

**AI CAN help with:**
- Cloud provider comparison (AWS vs GCP vs Azure)
- Cost modeling and forecasting
- Technology evaluation for new services
- Capacity planning and growth projections
- Competitive infrastructure analysis
- Architecture documentation generation
- Migration planning and risk assessment

**AI CANNOT:**
- Make final architecture decisions (Cloud Architect decides)
- Commit to specific cloud providers without approval
- Override security requirements
- Make cost commitments without validation

## Common Workflows

### Workflow 1: Cloud Architecture Design

```
1. Cloud Architect: "Design cloud architecture for new product"
2. AI: Read product requirements and expected scale
3. AI: Propose high-level architecture with:
   - Compute strategy (containers, serverless, VMs)
   - Database choices
   - Networking design
   - Security controls
   - Cost estimate
4. AI: Validate against infrastructure standards
5. AI: Check compliance and security requirements
6. Cloud Architect: Reviews, provides feedback
7. AI: Generate architecture decision record (ADR)
```

### Workflow 2: Infrastructure Cost Optimization

```
1. Cloud Architect: "Analyze current infrastructure costs and suggest optimizations"
2. AI: Review infrastructure code and configurations
3. AI: Identify cost optimization opportunities:
   - Right-sizing instances
   - Reserved capacity commitments
   - Data transfer optimization
   - Unused resources
4. AI: Estimate potential savings
5. AI: Assess risk and effort for each optimization
6. Cloud Architect: Prioritizes recommendations
```

### Workflow 3: Disaster Recovery Planning

```
1. Cloud Architect: "Create DR plan for critical services"
2. AI: Identify critical services and dependencies
3. AI: Check current backup and replication configs
4. AI: Propose DR strategy meeting RTO/RPO requirements
5. AI: Draft runbook for failover procedures
6. AI: Suggest DR testing schedule
7. Cloud Architect: Reviews and approves
```

## Cross-Role Collaboration

### With CTO/VP Engineering
- **Cloud Architect Creates → CTO Consumes:** Infrastructure standards, architecture proposals
- **Cloud Architect Consumes ← CTO Creates:** Engineering strategy, technical vision
- **AI should facilitate:** Ensuring infrastructure supports engineering goals

### With Security Engineer
- **Cloud Architect Creates → Security Consumes:** Network designs, access control models
- **Cloud Architect Consumes ← Security Creates:** Security requirements, compliance controls
- **AI should facilitate:** Security validation in architecture designs

### With Platform Engineers
- **Cloud Architect Creates → Platform Engineers Consume:** Infrastructure standards, platform architecture
- **Cloud Architect Consumes ← Platform Engineers Create:** Platform requirements, operational feedback
- **AI should facilitate:** Translating standards into implementable platform features

### With DevOps Engineers
- **Cloud Architect Creates → DevOps Consumes:** Infrastructure designs, deployment patterns
- **Cloud Architect Consumes ← DevOps Creates:** Operational insights, infrastructure as code
- **AI should facilitate:** Ensuring designs are operationally feasible

## Document References

### Documents Cloud Architect Creates
- `/infrastructure-standards.md`
- `/docs/architecture-decision-records/infrastructure-*.md`
- `/docs/cloud-strategy.md` (if exists)
- `/docs/disaster-recovery-plan.md`

### Documents Cloud Architect References
- `/engineering-standards.md`
- `/security-policy.md`
- `/data-governance.md`
- `/objectives-and-key-results.md`
- `/strategy.md`

### Templates Cloud Architect Uses
- `/docs/templates/architecture-decision-record-template.md`
- `/docs/templates/technical-design-document-template.md`

## Common Pitfalls

### Pitfall 1: Architecture Without Cost Analysis
**Bad:** Proposing architecture without cost estimates
**Good:** Every architecture includes detailed cost breakdown (initial + monthly)
**AI should flag:** "This architecture proposal doesn't include cost analysis. Add estimated costs for compute, storage, network, and managed services."

### Pitfall 2: Missing Disaster Recovery
**Bad:** Architecture with no DR plan or unclear RTO/RPO
**Good:** Explicit DR strategy meeting company standards (RTO: 4 hours, RPO: 1 hour)
**AI should flag:** "This design doesn't specify disaster recovery approach. Add backup strategy, failover procedures, and verify RTO/RPO requirements."

### Pitfall 3: Single Points of Failure
**Bad:** Architecture with critical single points of failure
**Good:** Redundancy for all critical components
**AI should flag:** "The database is a single point of failure. Consider multi-AZ deployment or read replicas."

### Pitfall 4: Over-Engineering
**Bad:** Complex architecture for simple use case
**Good:** Architecture complexity matches actual requirements and scale
**AI should flag:** "This architecture may be over-engineered for the expected scale of 100 users. Consider simpler alternatives."

## Example Interactions

### Example 1: New Product Architecture Review

**Cloud Architect:** "Review the proposed architecture for the new analytics product. Expected scale: 1000 enterprise customers, 10TB data/month."

**AI Response:**
```
I've reviewed the architecture proposal. Here's my analysis:

✅ Strengths:
- Uses managed services (reduces operational burden)
- Multi-AZ deployment for high availability
- Proper network segmentation

⚠️ Concerns:
1. **Cost**: Estimated $15K/month. Suggest reserved instances to reduce by 30%
2. **Data residency**: No multi-region strategy for EU customers (GDPR requirement)
3. **Disaster recovery**: Backup strategy defined but no documented failover procedures

📋 Required Before Approval:
- [ ] Add cost optimization plan (reserved capacity, spot instances where appropriate)
- [ ] Design multi-region deployment for EU data residency
- [ ] Create DR runbook for failover procedures
- [ ] Specify monitoring strategy (metrics, alerts, dashboards)

✏️ Architecture Decision Record:
Should I create an ADR documenting this architecture decision? If approved, I'll include the rationale for managed services vs self-hosted, cost trade-offs, and security controls.
```

### Example 2: Infrastructure Cost Optimization

**Cloud Architect:** "Our AWS bill is $50K/month. Identify cost savings opportunities."

**AI Response:**
```
I've analyzed the infrastructure costs. Here are optimization opportunities:

💰 High-Impact Savings:
1. **EC2 Right-Sizing** - $8K/month (40 over-provisioned instances)
   - Risk: Low | Effort: 2 weeks
2. **Reserved Instances** - $6K/month (commit to 1-year for production workloads)
   - Risk: Low | Effort: 1 week
3. **S3 Lifecycle Policies** - $3K/month (move old logs to Glacier)
   - Risk: None | Effort: 1 week

💡 Medium-Impact Savings:
4. **Database Right-Sizing** - $2K/month (RDS instances oversized)
   - Risk: Medium | Effort: 2 weeks (requires testing)
5. **Data Transfer Optimization** - $1.5K/month (use VPC endpoints)
   - Risk: Low | Effort: 1 week

**Total Potential Savings: $20.5K/month (41% reduction)**

Would you like me to create a detailed implementation plan for these optimizations?
```

## Success Metrics for AI Collaboration

- All architecture designs include cost analysis before approval
- Infrastructure standards are consistently applied across all projects
- Disaster recovery requirements met for all critical services (RTO/RPO)
- Security requirements validated in all architecture reviews
- Cost optimizations identified proactively (quarterly reviews)
- Architecture decisions documented in ADRs with clear trade-offs

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Organization
