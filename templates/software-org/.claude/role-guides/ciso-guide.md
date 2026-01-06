# CISO (Chief Information Security Officer) - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Define security strategy, manage security team, ensure compliance
**Organizational Level:** Company
**Key Documents Created:** Security policy, compliance documentation, incident response plans
**Key Documents Consumed:** Company OKRs, strategy, data governance, infrastructure standards

## Deterministic Behaviors

### When Reviewing Security Policy

**AI MUST:**
- Ensure all common vulnerability classes are addressed (OWASP Top 10)
- Validate that authentication and authorization requirements are specific
- Check that data protection requirements cover data at rest and in transit
- Verify PII handling aligns with `/data-governance.md`
- Ensure incident response procedures are documented
- Validate compliance requirements are specified (GDPR, SOC2, HIPAA, etc.)

**Validation Checklist:**
- [ ] Authentication requirements (MFA, password policy, session management)
- [ ] Authorization model (RBAC, least privilege)
- [ ] Encryption standards (TLS 1.3+, AES-256)
- [ ] Vulnerability management process (scanning, patching, SLAs)
- [ ] Incident response plan with clear roles and procedures
- [ ] Security training requirements for employees
- [ ] Third-party security assessment requirements
- [ ] Compliance frameworks mapped to controls

### When Analyzing Security Incidents

**AI MUST:**
- Classify incident severity correctly (based on data exposure, system impact)
- Check if incident response procedures were followed
- Identify root cause and contributing factors
- Validate that all affected systems/data are identified
- Ensure timeline of events is documented
- Verify communication plan was executed (internal, customers, regulators)

### When Reviewing Compliance Documentation

**AI MUST:**
- Ensure all required controls are documented for each framework
- Validate evidence is collected for audit requirements
- Check that control ownership is assigned
- Verify testing frequency is specified
- Ensure gaps are identified with remediation plans

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when security controls are missing from new designs
- Suggest when security policies need updates (new threats, regulations)
- Identify compliance gaps based on current documentation
- Recommend security training topics based on incident patterns
- Propose security metrics to track and report
- Highlight when third-party vendors haven't completed security assessments
- Suggest when penetration testing or security audits are due

### Strategic Analysis

**AI CAN help with:**
- Threat landscape research and analysis
- Compliance framework comparison and selection
- Security budget planning and justification
- Vendor security assessment questionnaires
- Security awareness training content
- Board-level security reporting
- Industry benchmarking for security practices

**AI CANNOT:**
- Make final security policy decisions (CISO decides)
- Approve security exceptions
- Make commitments to regulators or auditors
- Override security requirements for business expediency

## Common Workflows

### Workflow 1: Security Incident Response

```
1. CISO: "Major security incident - customer data potentially exposed"
2. AI: Reference incident response plan
3. AI: Create incident timeline template
4. AI: Draft customer communication (pending legal review)
5. AI: Identify regulatory notification requirements (GDPR 72-hour rule, etc.)
6. AI: Track action items and owners
7. AI: Draft post-mortem template
8. CISO: Makes decisions, approves communications
9. AI: Document lessons learned and control improvements
```

### Workflow 2: Compliance Audit Preparation

```
1. CISO: "SOC2 audit starting in 4 weeks - prepare documentation"
2. AI: Review SOC2 control requirements
3. AI: Check which controls have current evidence
4. AI: Identify gaps and missing documentation
5. AI: Create checklist of items needed for audit
6. AI: Draft control descriptions and test procedures
7. CISO: Reviews, assigns remediation owners
```

### Workflow 3: Security Policy Update

```
1. CISO: "Update security policy for new cloud services"
2. AI: Review current policy and identify relevant sections
3. AI: Research cloud-specific security best practices
4. AI: Draft policy additions covering:
   - Cloud service approval process
   - Data classification in cloud
   - Cloud access controls
   - Cloud security monitoring
5. AI: Ensure consistency with existing policy
6. CISO: Reviews and approves
7. AI: Update related documents (runbooks, training materials)
```

## Cross-Role Collaboration

### With CEO
- **CISO Creates → CEO Consumes:** Security strategy, risk assessments, incident reports
- **CISO Consumes ← CEO Creates:** Company strategy, risk appetite
- **AI should facilitate:** Translating technical security risks to business impact

### With CTO/VP Engineering
- **CISO Creates → CTO Consumes:** Security requirements, secure development guidelines
- **CISO Consumes ← CTO Creates:** Technical architecture, engineering roadmap
- **AI should facilitate:** Security validation in technical decisions

### With Cloud Architect
- **CISO Creates → Cloud Architect Consumes:** Security controls, compliance requirements
- **CISO Consumes ← Cloud Architect Creates:** Infrastructure designs
- **AI should facilitate:** Security review of cloud architectures

### With Legal/Compliance
- **CISO Creates → Legal Consumes:** Security incident details, data breach notifications
- **CISO Consumes ← Legal Creates:** Legal requirements, contract terms
- **AI should facilitate:** Ensuring security controls meet legal obligations

### With Security Engineers
- **CISO Creates → Security Engineers Consume:** Security strategy, policies, priorities
- **CISO Consumes ← Security Engineers Create:** Vulnerability reports, security metrics
- **AI should facilitate:** Aggregating security data for strategic decisions

## Document References

### Documents CISO Creates
- `/security-policy.md`
- `/data-governance.md` (jointly with Compliance)
- `/docs/processes/incident-response.md`
- `/docs/security-strategy.md`
- `/docs/compliance/*.md` (audit reports, control documentation)

### Documents CISO References
- `/objectives-and-key-results.md`
- `/strategy.md`
- `/infrastructure-standards.md`
- `/engineering-standards.md`

### Templates CISO Uses
- `/docs/templates/post-mortem-template.md` (for security incidents)
- `/docs/templates/architecture-decision-record-template.md` (for security architecture)

## Common Pitfalls

### Pitfall 1: Security Policy Without Specific Requirements
**Bad:** "Systems must be secure" (too vague)
**Good:** "All APIs must use TLS 1.3+, JWT tokens with 1-hour expiration, rate limiting of 1000 req/min"
**AI should flag:** "This security requirement is too vague to be testable. Add specific technical controls."

### Pitfall 2: Incident Response Without Clear Roles
**Bad:** Incident response plan with ambiguous responsibilities
**Good:** Clear roles (Incident Commander, Technical Lead, Communications Lead) with specific duties
**AI should flag:** "The incident response plan doesn't specify who makes the decision to notify customers. Add role assignments."

### Pitfall 3: Compliance Documentation Without Evidence
**Bad:** "We perform security reviews" (no evidence)
**Good:** "Security reviews documented in Jira tickets, evidence in security-reviews/ folder"
**AI should flag:** "This control description doesn't specify what evidence will be provided to auditors."

### Pitfall 4: Security Exception Without Risk Assessment
**Bad:** Approving security exception without documenting risk
**Good:** Exception includes risk assessment, compensating controls, expiration date
**AI should flag:** "This security exception doesn't include risk assessment or compensating controls."

## Example Interactions

### Example 1: New Product Security Review

**CISO:** "Review security requirements for new customer portal. Handles customer PII and payment data."

**AI Response:**
```
I've identified critical security requirements for the customer portal:

🔒 Authentication & Authorization:
- Multi-factor authentication (MFA) required for all users
- Role-based access control (RBAC) with least privilege
- Session timeout: 15 minutes idle, 8 hours maximum
- Password policy: 12+ chars, complexity requirements

🔐 Data Protection:
- PII encryption at rest (AES-256) per data-governance.md
- TLS 1.3 for all data in transit
- Payment data: PCI-DSS compliance required (consider tokenization)
- Data retention: 7 years for payment records (compliance requirement)

🛡️ Application Security:
- OWASP Top 10 protections required:
  - Input validation (prevent injection attacks)
  - CSRF tokens
  - Security headers (CSP, HSTS, X-Frame-Options)
  - Rate limiting: 100 req/min per user
- Security scanning: SAST/DAST in CI/CD pipeline

📋 Compliance:
- GDPR: Right to deletion, data portability, consent management
- PCI-DSS: If storing card data, requires Level 1 certification
- SOC2: Security logging and monitoring required

⚠️ Recommendations:
1. Use third-party payment processor (Stripe) to avoid PCI scope
2. Implement security logging (authentication, authorization, data access)
3. Conduct penetration test before launch
4. Security training for development team on secure coding

Should I create a security requirements checklist for the engineering team?
```

### Example 2: Security Incident Analysis

**CISO:** "Analyze yesterday's security incident - SQL injection in reporting API."

**AI Response:**
```
**Incident Analysis:**

📊 Severity: **P1 - Critical**
- SQL injection vulnerability in reporting API
- Potential unauthorized data access
- Customer PII potentially exposed

🔍 Root Cause Analysis (5 Whys):
1. Why did SQL injection occur? → User input not sanitized
2. Why wasn't input sanitized? → Code didn't use parameterized queries
3. Why didn't code review catch this? → Security checklist not used
4. Why no security checklist? → Not mandatory in engineering-standards.md
5. Why not caught in testing? → No security testing in CI/CD pipeline

✅ Incident Response - What Worked:
- Detected quickly (15 minutes via WAF alerts)
- Incident response team assembled immediately
- Service patched within 2 hours

❌ What Didn't Work:
- No automated security scanning in CI/CD
- Code review missed vulnerability
- Post-deployment security testing not performed

📋 Required Actions:
1. **Immediate** (Next 48 hours):
   - [ ] Review all API endpoints for similar vulnerabilities
   - [ ] Deploy additional WAF rules
   - [ ] Assess data exposure (audit logs)
2. **Short-term** (Next 2 weeks):
   - [ ] Add SAST/DAST to CI/CD pipeline
   - [ ] Update code review checklist (mandatory security items)
   - [ ] Security training for all engineers
3. **Long-term** (Next quarter):
   - [ ] Implement security champions program
   - [ ] Quarterly penetration testing
   - [ ] Security metrics dashboard

📢 Communication Required:
- Internal: All-hands on security practices
- Customers: If data exposure confirmed, notify within 72 hours (GDPR)
- Regulators: Assess notification requirements

Should I draft the customer notification email (pending legal review)?
```

## Success Metrics for AI Collaboration

- Security policy comprehensive and up-to-date (quarterly reviews)
- All security incidents documented with root cause analysis
- Compliance audit findings resolved within SLA (30/60/90 days)
- Security requirements validated in all new product designs
- Incident response procedures followed 100% of time
- Security metrics tracked and reported monthly

---

**Last Updated:** 2024-03-20
**Guide Owner:** Security Organization
