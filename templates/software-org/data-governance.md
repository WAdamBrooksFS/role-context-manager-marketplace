# Data Governance

<!-- LLM: Data governance is CRITICAL for compliance and customer trust. When reviewing any code or design that handles data, especially PII, validate against these requirements. Flag potential violations immediately. -->

**Status:** Static | **Update Frequency:** Annual (or when regulations change)
**Primary Roles:** CISO, Compliance Officer, Data Engineers, All Engineers
**Related Documents:** `/security-policy.md`, `/compliance-requirements.md`

## Purpose

This document defines how we collect, store, process, and delete data, especially personally identifiable information (PII) and sensitive data. Compliance with data protection regulations (GDPR, CCPA, HIPAA) is mandatory.

---

## Data Classification

| Class | Definition | Examples | Retention | Access |
|-------|------------|----------|-----------|--------|
| **Public** | Publicly available | Marketing materials, public docs | Indefinite | Everyone |
| **Internal** | Internal use only | OKRs, roadmaps, employee data | Per policy | Employees |
| **Confidential** | Sensitive business data | Customer lists, revenue, contracts | 7 years | Need-to-know |
| **Restricted** | Highly sensitive/regulated | PII, PHI, payment data, SSNs | Minimum required | Strictly controlled |

---

## Personally Identifiable Information (PII)

### What is PII?

**Direct Identifiers:** Name, email, phone, SSN, driver's license, passport, biometric data
**Indirect Identifiers:** IP address, device ID, geolocation, browsing history (when combined)

### PII Handling Requirements

**MUST:**
- Minimize collection (only collect what's necessary)
- Obtain explicit consent before collection
- Encrypt PII at rest (AES-256) and in transit (TLS 1.2+)
- Log all PII access for audit trails
- Implement right to access, rectification, deletion (GDPR/CCPA)
- Anonymize PII in non-production environments
- Delete PII when no longer needed (retention limits)

**MUST NOT:**
- Store PII unnecessarily
- Share PII with third parties without consent
- Log PII in application logs
- Use PII in test data
- Store PII in plain text

### Data Subject Rights

**Right to Access:** Users can request all data we have about them
**Right to Rectification:** Users can correct inaccurate data
**Right to Erasure:** Users can request deletion ("right to be forgotten")
**Right to Portability:** Users can export their data in machine-readable format
**Right to Object:** Users can opt-out of certain processing (e.g., marketing)

---

## Data Retention

| Data Type | Retention Period | Rationale | Deletion Method |
|-----------|-----------------|-----------|-----------------|
| User account data | Active + 90 days after deletion request | GDPR compliance | Hard delete + anonymize logs |
| Transaction logs | 7 years | Financial regulations | Automatic deletion |
| Application logs | 90 days | Operational necessity | Rolling deletion |
| Backups with PII | 30 days | Disaster recovery | Encrypted, then deleted |
| Analytics data | Anonymize after 2 years | Business intelligence | Anonymization (not deletion) |

---

## Data Minimization

**Principle:** Collect only the data necessary for the stated purpose.

**Before collecting any data field, ask:**
1. Is this data necessary for the feature to work?
2. Can we accomplish the goal without this data?
3. Can we use anonymized or aggregated data instead?
4. Do we have user consent to collect this?

---

## Consent Management

**Explicit Consent Required For:**
- Marketing emails
- Analytics cookies
- Data sharing with third parties
- Sensitive data processing (health, financial)

**Consent MUST be:**
- Freely given (not bundled with service acceptance)
- Specific (clear what it's for)
- Informed (user knows what they're consenting to)
- Unambiguous (affirmative action required, no pre-checked boxes)
- Revocable (users can withdraw consent easily)

---

## Data Security

*See `/security-policy.md` for comprehensive security requirements*

**Encryption:**
- PII at rest: AES-256 encryption
- PII in transit: TLS 1.2+ (no self-signed certs in production)
- Encryption keys: Stored separately in key management system (KMS)

**Access Control:**
- Principle of least privilege
- MFA required for PII access
- Audit logging for all PII access
- Regular access reviews (quarterly)

---

## Cross-Border Data Transfers

**EU/EEA Data:**
- GDPR applies to EU citizens' data regardless of company location
- Data transfers outside EU require Standard Contractual Clauses (SCCs) or adequacy decision
- Notify users of cross-border transfers

**US State Laws (CCPA, CPRA, etc.):**
- Apply to California residents' data
- Similar requirements to GDPR (access, deletion, opt-out rights)

---

## Breach Notification

**If PII is compromised:**
1. **Immediate:** Notify security team and CISO
2. **Within 72 hours:** Notify data protection authorities (GDPR requirement)
3. **Within 30-72 hours:** Notify affected users (varies by regulation)
4. **Post-incident:** Conduct post-mortem, implement preventive measures

*See `/docs/processes/incident-response.md` for detailed process*

---

## Anonymization vs. Pseudonymization

**Anonymization (Irreversible):**
- Remove all identifiers permanently
- Data cannot be linked back to individuals
- GDPR no longer applies (not personal data)
- Use for analytics, research

**Pseudonymization (Reversible):**
- Replace identifiers with pseudonyms (e.g., hash user ID)
- Can be reversed with key (kept separately)
- Still considered PII under GDPR
- Use when need to link data but protect identity

---

## Third-Party Data Processors

**Before sharing data with vendors:**
- Data Processing Agreement (DPA) required
- Vendor must meet our security standards
- Audit vendor's security practices
- Ensure vendor complies with regulations (GDPR, CCPA)
- Document data sharing in privacy policy

**Required Vendor Certifications:**
- SOC 2 Type II (minimum)
- ISO 27001 (preferred)
- GDPR compliance attestation
- HIPAA Business Associate Agreement (BAA) if applicable

---

## Privacy by Design

**Requirements for new features:**
- Privacy impact assessment for features handling PII
- Default to most privacy-protective settings
- Minimize data collection
- Provide clear privacy notices
- Enable easy consent management
- Support data portability and deletion

---

## Data Governance Roles

**Data Protection Officer (DPO):** [Name] - Oversees compliance
**CISO:** [Name] - Security of data
**Compliance Officer:** [Name] - Regulatory compliance
**Engineers:** Implement controls, follow policies
**Product Managers:** Ensure features comply with data governance

---

**Last Updated:** [Date]
**Next Review:** [Date]
**Policy Owner:** [CISO + Compliance Officer]

<!-- LLM: When reviewing any feature that collects, stores, or processes user data, validate against this policy. Common violations to flag: collecting PII without consent, storing PII unencrypted, logging PII, using PII in test data, not providing deletion mechanism. -->
