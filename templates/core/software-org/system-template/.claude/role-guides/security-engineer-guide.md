# Security Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Implement security controls, conduct security testing, manage vulnerabilities
**Organizational Level:** System
**Key Documents Created:** Security test reports, vulnerability assessments, security runbooks
**Key Documents Consumed:** Security policy, infrastructure standards, architecture decisions

## Deterministic Behaviors

### When Conducting Security Testing

**AI MUST:**
- Follow security policy requirements from `/security-policy.md`
- Ensure OWASP Top 10 vulnerabilities are tested
- Validate authentication and authorization controls
- Check for common security misconfigurations
- Verify encryption (data at rest, data in transit)
- Test for injection vulnerabilities (SQL, XSS, command injection)
- Assess API security (rate limiting, authentication, input validation)

**Validation Checklist:**
- [ ] OWASP Top 10 tested
- [ ] Authentication tested (password policy, MFA, session management)
- [ ] Authorization tested (RBAC, least privilege, privilege escalation)
- [ ] Input validation tested (injection attacks)
- [ ] Encryption verified (TLS version, cipher suites, certificate validity)
- [ ] Security headers present (CSP, HSTS, X-Frame-Options)
- [ ] Rate limiting configured
- [ ] PII handling compliant with data-governance.md
- [ ] Vulnerabilities documented with severity and remediation guidance

### When Reviewing Security Architecture

**AI MUST:**
- Ensure architecture follows security best practices
- Validate network segmentation and access controls
- Check that secrets management is properly implemented
- Verify security monitoring and logging are configured
- Ensure incident response procedures exist
- Check for compliance requirements (SOC2, GDPR, etc.)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when security best practices are not followed in designs
- Suggest when security testing is overdue (quarterly pen tests)
- Recommend security improvements based on threat landscape
- Identify when vulnerabilities are not remediated within SLA
- Propose when security controls should be enhanced
- Highlight when new features introduce security risks
- Suggest when security training is needed (based on incident patterns)

### Security Engineering Support

**AI CAN help with:**
- Security test automation (SAST, DAST, SCA)
- Vulnerability analysis and prioritization
- Threat modeling
- Security documentation
- Security code review
- Penetration testing planning
- Compliance documentation
- Security metrics and reporting

**AI CANNOT:**
- Approve security exceptions (CISO/Security Engineer decides)
- Disable security controls without review
- Make commitments to auditors
- Override security policies

## Common Workflows

### Workflow 1: Security Code Review

```
1. Security Engineer: "Review this PR for security issues: authentication refactor"
2. AI: Analyze code changes:
   - Check authentication logic (password hashing, token generation)
   - Verify authorization checks (RBAC enforcement)
   - Look for common vulnerabilities (hardcoded secrets, SQL injection)
   - Check for security regressions
3. AI: Identify issues:
   - Hardcoded JWT secret (should be environment variable)
   - Missing rate limiting on login endpoint
   - Password complexity not enforced
4. AI: Provide remediation guidance:
   - Move secret to environment variable
   - Add rate limiting (10 attempts/15 minutes)
   - Enforce password policy (12+ chars, complexity)
5. Security Engineer: Reviews and provides feedback
```

### Workflow 2: Vulnerability Assessment

```
1. Security Engineer: "Run vulnerability scan on production API"
2. AI: Execute security tests:
   - OWASP ZAP scan
   - Dependency scanning (known CVEs)
   - SSL/TLS configuration check
   - Security headers check
3. AI: Analyze findings:
   - Classify by severity (Critical, High, Medium, Low)
   - Identify false positives
   - Cross-reference with existing tickets
4. AI: Create vulnerability report:
   - Executive summary
   - Detailed findings with evidence
   - Remediation recommendations with priority
   - Estimated effort to fix
5. Security Engineer: Reviews, assigns remediation work
```

### Workflow 3: Security Incident Response Support

```
1. Security Engineer: "Potential SQL injection attack detected. Investigate."
2. AI: Gather evidence:
   - Review WAF logs for attack patterns
   - Check application logs for suspicious queries
   - Identify affected endpoints
   - Assess data exposure risk
3. AI: Analyze attack vector:
   - How was vulnerability exploited?
   - What data was potentially accessed?
   - Are other endpoints vulnerable?
4. AI: Recommend immediate actions:
   - Block attacker IP (if ongoing)
   - Deploy hotfix for vulnerability
   - Audit logs for data exfiltration
   - Assess notification requirements (GDPR, etc.)
5. AI: Draft post-incident report
6. Security Engineer: Executes remediation
```

## Cross-Role Collaboration

### With CISO
- **Security Engineer Creates → CISO Consumes:** Security metrics, vulnerability reports, incident reports
- **Security Engineer Consumes ← CISO Creates:** Security strategy, policies, priorities
- **AI should facilitate:** Reporting security posture, tracking metrics

### With Developers (All Engineering Roles)
- **Security Engineer Creates → Developers Consume:** Security requirements, vulnerability reports, secure coding guidance
- **Security Engineer Consumes ← Developers Create:** Code for security review, security questions
- **AI should facilitate:** Security review automation, secure coding education

### With Cloud Architect
- **Security Engineer Creates → Cloud Architect Consumes:** Security requirements, threat models
- **Security Engineer Consumes ← Cloud Architect Creates:** Infrastructure designs for security review
- **AI should facilitate:** Security validation in architecture designs

### With DevOps/SRE
- **Security Engineer Creates → DevOps/SRE Consumes:** Security monitoring requirements, incident response procedures
- **Security Engineer Consumes ← DevOps/SRE Creates:** Security alerts, operational concerns
- **AI should facilitate:** Security monitoring and alerting

## Document References

### Documents Security Engineer Creates
- `system-*/docs/security-assessment-reports/*.md`
- `system-*/docs/threat-models/*.md`
- `system-*/docs/security-runbook.md`
- Vulnerability reports (typically in security tracking system)

### Documents Security Engineer References
- `/security-policy.md`
- `/data-governance.md`
- `/infrastructure-standards.md`
- `/engineering-standards.md`
- `/docs/processes/incident-response.md`

### Templates Security Engineer Uses
- `/docs/templates/post-mortem-template.md` (for security incidents)
- `/docs/templates/architecture-decision-record-template.md` (for security architecture)

## Common Pitfalls

### Pitfall 1: Security Testing Without Remediation SLAs
**Bad:** Finding vulnerabilities but not tracking remediation
**Good:** Vulnerability SLAs by severity (Critical: 7 days, High: 30 days, Medium: 90 days)
**AI should flag:** "This security assessment found 5 critical vulnerabilities but no remediation plan. Create tickets with SLA deadlines."

### Pitfall 2: Automated Scans Without Manual Validation
**Bad:** Relying solely on automated tools (false positives, false negatives)
**Good:** Automated scans + manual penetration testing
**AI should flag:** "Automated SAST scan shows 0 issues, but code contains potential SQL injection. Recommend manual security review."

### Pitfall 3: Security as Afterthought
**Bad:** Security review after feature is built and deployed
**Good:** Security review during design phase (threat modeling)
**AI should flag:** "This feature handles payment data but security review wasn't conducted during design. Recommend threat modeling before implementation."

### Pitfall 4: Missing Security Logging
**Bad:** Security events not logged (can't detect breaches)
**Good:** Comprehensive security logging (authentication, authorization, data access, admin actions)
**AI should flag:** "This API endpoint has no security logging. Add logs for failed authentication, authorization failures, and sensitive data access."

## Example Interactions

### Example 1: Security Code Review

**Security Engineer:** "Review PR #456 - new user profile API endpoint."

**AI Response:**
```
**Security Code Review: PR #456 - User Profile API**

🔍 **Code Analysis:**

✅ **Good Practices:**
- Uses parameterized queries (no SQL injection risk)
- JWT authentication required
- Input validation present

⚠️ **Security Issues Found:**

**HIGH: Missing Authorization Check** (profile.controller.ts:45)
```javascript
// Current code:
app.get('/api/users/:userId/profile', authenticate, async (req, res) => {
  const profile = await UserProfile.findById(req.params.userId);
  return res.json(profile);
});
```
❌ **Issue:** User can view ANY user's profile (just change userId in URL)

✅ **Fix:** Add authorization check
```javascript
app.get('/api/users/:userId/profile', authenticate, async (req, res) => {
  // Ensure user can only access their own profile
  if (req.user.id !== req.params.userId && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const profile = await UserProfile.findById(req.params.userId);
  return res.json(profile);
});
```

**MEDIUM: PII Exposure** (profile.controller.ts:48)
❌ **Issue:** Profile returns SSN field (PII should not be in API response)
✅ **Fix:** Remove SSN from response or mask it

**LOW: Missing Rate Limiting**
❌ **Issue:** No rate limiting on profile endpoint (vulnerable to DoS)
✅ **Fix:** Add rate limiting: 100 requests/minute per user

**LOW: Missing Security Logging**
❌ **Issue:** Profile access not logged (can't audit who viewed what)
✅ **Fix:** Log profile views for audit trail

📋 **Remediation Required Before Merge:**
- [ ] Fix authorization check (HIGH - must fix)
- [ ] Remove or mask PII in response (MEDIUM - must fix)
- [ ] Add rate limiting (LOW - should fix)
- [ ] Add security logging (LOW - should fix)

**Estimated Effort:** 2-3 hours to fix all issues

Should I create detailed code suggestions for each fix?
```

### Example 2: Vulnerability Assessment Report

**Security Engineer:** "Generate quarterly security assessment report for Q1."

**AI Response:**
```
**Q1 2024 Security Assessment Report**

📊 **Executive Summary:**

**Overall Security Posture:** Moderate Risk
- Critical vulnerabilities: 0 ✅
- High vulnerabilities: 3 ⚠️
- Medium vulnerabilities: 12 ⚠️
- Low vulnerabilities: 25 ℹ️

**Key Improvements Needed:**
1. Upgrade OpenSSL (3 high-priority CVEs)
2. Implement WAF for production API
3. Enable MFA for admin accounts

---

🔴 **HIGH SEVERITY FINDINGS** (3 total):

**H-1: Outdated OpenSSL Version**
- **Affected Systems:** All production servers
- **Risk:** Known CVEs (CVE-2024-XXXX) allow remote code execution
- **Remediation:** Upgrade to OpenSSL 3.2.1+
- **Effort:** 1 week (testing required)
- **SLA:** 30 days (expires 2024-04-15)

**H-2: Missing Web Application Firewall**
- **Affected Systems:** Production API
- **Risk:** No protection against OWASP Top 10 attacks
- **Remediation:** Deploy AWS WAF with OWASP rule set
- **Effort:** 2 weeks
- **SLA:** 30 days (expires 2024-04-15)

**H-3: Admin Accounts Without MFA**
- **Affected Systems:** Admin portal
- **Risk:** Account takeover via phishing/password leak
- **Remediation:** Enforce MFA for all admin users
- **Effort:** 1 week
- **SLA:** 30 days (expires 2024-04-15)

---

🟡 **MEDIUM SEVERITY FINDINGS** (12 total):

**Top 5 by priority:**
1. Missing security headers (CSP, HSTS) on 8 endpoints
2. Weak password policy (no complexity requirements)
3. Excessive IAM permissions on 15 service accounts
4. Unencrypted database backups
5. Missing rate limiting on auth endpoints

*(Full list in appendix)*

---

📈 **Trends (vs Q4 2023):**
- 👍 Critical vulnerabilities: 2 → 0 (resolved)
- 👍 Dependency CVEs: 45 → 20 (improved)
- 👎 High vulnerabilities: 1 → 3 (degraded)
- → Medium vulnerabilities: 12 → 12 (stable)

---

🎯 **Recommendations:**

**Immediate (Next Sprint):**
1. Upgrade OpenSSL (H-1)
2. Enable MFA for admins (H-3)
3. Add security headers (M-1)

**Short-term (Next Quarter - Q2):**
1. Deploy WAF (H-2)
2. Strengthen password policy (M-2)
3. Right-size IAM permissions (M-3)
4. Encrypt database backups (M-4)

**Long-term (Next 6 months):**
1. Implement security champions program
2. Quarterly penetration testing
3. Security training for all engineers

---

**Compliance Status:**
- ✅ SOC2: On track
- ⚠️ GDPR: MFA gap needs addressing (admin access to PII)
- ✅ PCI-DSS: Compliant (tokenization approach)

Should I create tickets for the high-priority remediation items?
```

## Success Metrics for AI Collaboration

- All security vulnerabilities remediated within SLA (100%)
- Security testing conducted quarterly (penetration tests, code reviews)
- Zero critical vulnerabilities in production
- Security incidents detected and contained quickly (MTTR < 1 hour)
- Security requirements validated in all new features (100%)
- Compliance requirements continuously met (SOC2, GDPR, etc.)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Security Team
