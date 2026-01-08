# DevOps Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Deploy and operate services, infrastructure as code
**Organizational Level:** Project
**Key Documents Created:** Infrastructure code, runbooks, deployment documentation
**Key Documents Consumed:** Infrastructure standards, technical designs, security policy

## Deterministic Behaviors

### When Writing Infrastructure as Code

**AI MUST:**
- Follow infrastructure standards from `/infrastructure-standards.md`
- Use version control for all infrastructure code
- Include proper naming conventions and tagging
- Implement security best practices (least privilege, encryption)
- Include monitoring and alerting
- Document disaster recovery procedures
- Never hardcode secrets (use secrets management)

**Validation Checklist:**
- [ ] Infrastructure code follows standards (Terraform/CloudFormation)
- [ ] Resources properly tagged (environment, owner, cost-center)
- [ ] Security groups follow least privilege
- [ ] Secrets in secrets manager (not hardcoded)
- [ ] Monitoring and alerts configured
- [ ] Backup and disaster recovery implemented
- [ ] Runbook created for operations
- [ ] Cost optimization considered

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest cost optimizations (right-sizing, reserved instances)
- Recommend security improvements
- Flag when disaster recovery is insufficient
- Identify monitoring gaps
- Propose automation opportunities
- Highlight configuration drift

### DevOps Support

**AI CAN help with:**
- Infrastructure as code generation
- Runbook creation
- Incident analysis and troubleshooting
- Automation scripting
- Cost analysis
- Security configuration
- Monitoring setup
- Deployment automation

## Common Workflows

### Workflow 1: Deploy New Service

```
1. DevOps Engineer: "Deploy new API service to production"
2. AI: Create deployment plan:
   - Infrastructure (load balancer, compute, database)
   - CI/CD pipeline configuration
   - Monitoring and alerts
   - Runbook for operations
3. AI: Generate infrastructure code (Terraform)
4. AI: Configure deployment pipeline
5. AI: Set up monitoring dashboards and alerts
6. DevOps Engineer: Reviews, tests in staging, deploys
```

### Workflow 2: Incident Response

```
1. DevOps Engineer: "Service down, investigate"
2. AI: Gather information:
   - Check monitoring dashboards
   - Review recent deployments
   - Check error logs
3. AI: Identify root cause:
   - Recent deployment caused issue
4. AI: Propose remediation:
   - Rollback to previous version
   - Or: Apply hotfix
5. DevOps Engineer: Executes fix, documents incident
```

## Common Pitfalls

### Pitfall 1: Hardcoded Secrets
**Bad:** Secrets in infrastructure code
**Good:** Secrets in AWS Secrets Manager or similar
**AI should flag:** "Database password hardcoded. Use secrets manager."

### Pitfall 2: Missing Monitoring
**Bad:** Service deployed without monitoring
**Good:** Comprehensive monitoring and alerting
**AI should flag:** "Service has no health check or monitoring. Add CloudWatch metrics and alerts."

### Pitfall 3: No Disaster Recovery
**Bad:** No backups or recovery plan
**Good:** Automated backups, tested recovery procedures
**AI should flag:** "Database has no backup configured. Add automated backups per infrastructure-standards.md (RPO: 1 hour)."

## Success Metrics for AI Collaboration

- Infrastructure code follows standards (100%)
- All services have monitoring and runbooks
- Deployments automated and reliable
- Incident MTTR low (< 1 hour)
- Zero hardcoded secrets
- Disaster recovery tested regularly

---

**Last Updated:** 2024-03-20
**Guide Owner:** Infrastructure Team
