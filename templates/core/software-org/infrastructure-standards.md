# Infrastructure Standards

<!-- LLM: Infrastructure changes can impact security, reliability, and cost. Validate all infrastructure proposals against these standards. Ensure infrastructure-as-code is used, reviewed, and tested before production. -->

**Status:** Static | **Update Frequency:** Annual
**Primary Roles:** Cloud Architect, DevOps Engineers, SREs, Platform Engineers
**Related Documents:** `/security-policy.md`, `/engineering-standards.md`

## Purpose

This document defines standards for cloud infrastructure, deployment, monitoring, and operations.

---

## Cloud Architecture Principles

1. **Cloud-Native Design**: Build for cloud from the start (not lift-and-shift)
2. **Multi-Region Capable**: Design for geographic distribution
3. **Auto-Scaling**: Scale horizontally, not vertically
4. **Immutable Infrastructure**: Replace, don't modify
5. **Infrastructure as Code**: All infrastructure versioned and reviewable

---

## Infrastructure as Code (IaC)

**Required:**
- **Tool**: Terraform (preferred) or CloudFormation
- **Version Control**: All IaC in git
- **Code Review**: IaC changes require peer review
- **Testing**: Test in non-prod before applying to prod
- **State Management**: Remote state backend (S3 + DynamoDB for Terraform)

**IaC Standards:**
```terraform
# Example: Terraform module structure
modules/
  vpc/
    main.tf
    variables.tf
    outputs.tf
    README.md

environments/
  dev/
  staging/
  prod/
```

---

## Compute

**Containerization:**
- **Standard**: Docker containers
- **Orchestration**: Kubernetes
- **Base Images**: Use approved base images only (security scanned)
- **Image Registry**: Private registry (AWS ECR, GCP Artifact Registry)

**Serverless:**
- **Allowed**: AWS Lambda, Google Cloud Functions for appropriate use cases
- **Constraints**: < 15min execution time, stateless, event-driven

**Virtual Machines:**
- **Discouraged**: Prefer containers/serverless
- **If Required**: Use auto-scaling groups, immutable deployments

---

## Networking

**VPC Design:**
- Separate VPCs for prod/non-prod
- Private subnets for databases and backend services
- Public subnets only for load balancers
- NAT gateways for outbound traffic from private subnets

**Security Groups / Firewall Rules:**
- Deny by default, allow explicitly
- No 0.0.0.0/0 ingress except load balancers (and only on required ports)
- Document all rules with purpose

**Load Balancing:**
- Application Load Balancer (ALB) for HTTP/HTTPS
- Network Load Balancer (NLB) for TCP
- Health checks required
- TLS termination at load balancer

---

## Data Storage

**Databases:**
- **Relational**: PostgreSQL (preferred), MySQL
- **NoSQL**: MongoDB, DynamoDB (use case specific)
- **Managed Services**: Use managed databases (RDS, Cloud SQL) over self-hosted
- **Backups**: Automated daily backups, 30-day retention minimum
- **High Availability**: Multi-AZ deployment for production

**Object Storage:**
- S3 (AWS), Cloud Storage (GCP)
- Encryption at rest (server-side)
- Versioning enabled for critical data
- Lifecycle policies for cost optimization

**Caching:**
- Redis (ElastiCache, Cloud Memorystore)
- Set appropriate TTLs
- Monitor cache hit rates

---

## Security

**Secrets Management:**
- **Tools**: AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager
- **Never**: Store secrets in code, config files, or environment variables in source control
- **Rotation**: Automatic rotation every 90 days

**Network Security:**
- VPN for employee access to non-public resources
- Bastion hosts for SSH access (no direct SSH to production)
- TLS 1.2+ for all traffic
- Web Application Firewall (WAF) for public endpoints

**Identity & Access Management (IAM):**
- Least privilege principle
- MFA required for production access
- Service accounts for application access (not user accounts)
- Regular access audits (quarterly)

---

## Monitoring & Observability

**Required for All Services:**
- **Metrics**: Request rate, error rate, latency (RED metrics)
- **Logs**: Structured JSON logs, centralized logging
- **Traces**: Distributed tracing for microservices
- **Dashboards**: Real-time service health dashboards
- **Alerts**: On-call alerts for critical issues

**Tools:**
- **Metrics**: Prometheus, CloudWatch, Datadog
- **Logs**: ELK Stack, CloudWatch Logs, Google Cloud Logging
- **Tracing**: Jaeger, AWS X-Ray, OpenTelemetry
- **APM**: Datadog, New Relic, Dynatrace

**SLA/SLO:**
- Define Service Level Objectives (SLOs) for each service
- Target: 99.9% uptime for production services
- Error budget management

---

## Deployment

**CI/CD Pipeline:**
- Automated builds on every commit
- Automated tests (unit, integration, security scans)
- Automated deployments to dev/staging
- Manual approval for production

**Deployment Strategies:**
- **Blue-Green**: Preferred for large updates
- **Canary**: Gradual rollout (10% → 50% → 100%)
- **Rolling**: Incremental replacement
- **Feature Flags**: Enable/disable features without deployment

**Rollback Plan:**
- Every deployment must have rollback procedure
- Automated rollback on critical errors
- Maximum 15-minute rollback time

---

## Disaster Recovery

**Backup Strategy:**
- **RTO (Recovery Time Objective)**: 4 hours
- **RPO (Recovery Point Objective)**: 1 hour
- Regular backup testing (quarterly)
- Cross-region backups for critical data

**Incident Response:**
- On-call rotation (24/7)
- Runbooks for common incidents
- Post-mortem after every major incident

---

## Cost Optimization

**Practices:**
- Right-size instances (monitor utilization)
- Use reserved instances for predictable workloads
- Auto-scaling to match demand
- Delete unused resources (automated cleanup)
- Monitor costs daily, alert on anomalies

**Budget Alerts:**
- Set budget alerts at 50%, 80%, 100% of monthly budget
- Tag resources by team/product for cost allocation

---

## Compliance

**Required:**
- Data residency controls (EU data in EU region)
- Audit logging for all infrastructure changes
- Encryption at rest and in transit
- Regular security scanning
- SOC 2 compliance

---

**Last Updated:** [Date]
**Owner:** [Cloud Architect + CISO]

<!-- LLM: Infrastructure changes have broad impact. Ensure all infrastructure proposals use IaC, follow security best practices, include monitoring, and have rollback plans. -->
