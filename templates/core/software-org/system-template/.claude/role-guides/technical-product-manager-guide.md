# Technical Product Manager (TPM) - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Manage technical products (APIs, platforms, developer tools)
**Organizational Level:** System or Product
**Key Documents Created:** Technical PRDs, API specifications, developer documentation
**Key Documents Consumed:** Product strategy, engineering standards, system architecture

## Deterministic Behaviors

### When Creating Technical PRDs

**AI MUST:**
- Ensure all required sections are completed (use PRD template)
- Validate that API specifications are included (endpoints, request/response schemas)
- Check that developer use cases are documented
- Verify technical success metrics are measurable
- Ensure backward compatibility is addressed
- Validate that security requirements are specified
- Check that performance requirements are quantified

**Validation Checklist:**
- [ ] Problem statement clear (what developer pain point does this solve?)
- [ ] API specification complete (endpoints, methods, authentication, rate limits)
- [ ] Request/response schemas documented (with examples)
- [ ] Error codes and handling documented
- [ ] Developer use cases with code examples
- [ ] Success metrics defined (adoption, API usage, latency, error rates)
- [ ] Backward compatibility strategy (versioning approach)
- [ ] Security requirements (authentication, authorization, data protection)
- [ ] Performance requirements (latency SLA, throughput limits)
- [ ] Documentation plan (API reference, quickstart guides, tutorials)

### When Reviewing API Designs

**AI MUST:**
- Ensure API follows REST or GraphQL best practices
- Validate consistency with existing API patterns
- Check that error handling is comprehensive
- Verify rate limiting is specified
- Ensure versioning strategy is documented
- Check that API is developer-friendly (intuitive, well-documented)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when API designs are inconsistent with existing patterns
- Suggest when developer documentation is missing or unclear
- Recommend when API versioning is needed (breaking changes)
- Identify when performance SLAs are unrealistic or missing
- Propose when API features could improve developer experience
- Highlight when backward compatibility is broken
- Suggest when API usage metrics indicate adoption issues

### Technical Product Management Support

**AI CAN help with:**
- Technical PRD drafting and refinement
- API specification creation (OpenAPI/Swagger)
- Developer documentation generation
- Code examples for documentation
- Competitive API analysis
- Developer persona development
- Technical feasibility assessment
- API usage analytics and insights

**AI CANNOT:**
- Make final product decisions (TPM decides)
- Commit to API SLAs without engineering validation
- Override engineering architecture decisions
- Make promises about delivery timelines without team input

## Common Workflows

### Workflow 1: New API Feature PRD

```
1. TPM: "Create PRD for new webhook API"
2. AI: Gather requirements:
   - What events trigger webhooks?
   - What data is included in webhook payload?
   - How do developers register webhooks?
   - Retry logic for failed webhooks?
3. AI: Draft PRD with:
   - Problem statement (why developers need webhooks)
   - API specification (endpoints, schemas)
   - Developer use cases with code examples
   - Security considerations
   - Success metrics
4. AI: Generate OpenAPI spec
5. AI: Create developer documentation draft
6. TPM: Reviews, refines with engineering input
```

### Workflow 2: API Backward Compatibility Review

```
1. TPM: "Evaluate if this API change breaks backward compatibility"
2. AI: Analyze proposed changes:
   - Removed endpoints or parameters?
   - Changed response schemas?
   - New required fields?
3. AI: Assess impact:
   - Breaking changes identified
   - Number of API consumers affected
   - Migration effort required
4. AI: Recommend approach:
   - Option 1: New API version (v2)
   - Option 2: Deprecation period (6 months)
   - Option 3: Additive-only changes
5. TPM: Decides on versioning strategy
```

### Workflow 3: Developer Experience Analysis

```
1. TPM: "Analyze API adoption - why aren't developers using the new feature?"
2. AI: Review data:
   - API usage metrics (calls, unique users, error rates)
   - Documentation views (are developers finding docs?)
   - Support tickets (what problems are developers facing?)
   - Time to first successful API call
3. AI: Identify friction points:
   - Complex authentication setup?
   - Unclear documentation?
   - Missing code examples?
   - Poor error messages?
4. AI: Propose improvements:
   - Simplify authentication flow
   - Add quickstart guide
   - Include code examples in 5 languages
   - Improve error messages
5. TPM: Prioritizes improvements
```

## Cross-Role Collaboration

### With Developers (API Consumers)
- **TPM Creates → Developers Consume:** API specifications, documentation, code examples
- **TPM Consumes ← Developers Create:** Feedback, feature requests, bug reports
- **AI should facilitate:** Improving developer experience, reducing friction

### With Engineering Team
- **TPM Creates → Engineers Consume:** Technical PRDs, API specs, requirements
- **TPM Consumes ← Engineers Create:** Technical feasibility, architecture proposals
- **AI should facilitate:** Product-engineering trade-offs, technical validation

### With Product Managers
- **TPM Creates → PMs Consume:** Platform capabilities, API roadmap
- **TPM Consumes ← PMs Create:** Product requirements, use cases
- **AI should facilitate:** Translating product needs to technical requirements

### With Technical Writers
- **TPM Creates → Tech Writers Consume:** API specifications, feature descriptions
- **TPM Consumes ← Tech Writers Create:** Polished documentation, tutorials
- **AI should facilitate:** Draft documentation, ensure technical accuracy

## Document References

### Documents TPM Creates
- `system-*/docs/product-requirements-documents/api-*.md` (technical PRDs)
- `system-*/docs/api-specification.yaml` (OpenAPI specs)
- `system-*/docs/api-documentation.md`
- `product-*/roadmap.md` (API roadmap)

### Documents TPM References
- `/product-vision.md`
- `/engineering-standards.md`
- `/security-policy.md`
- `system-*/docs/architecture-decision-records/*.md`

### Templates TPM Uses
- `/docs/templates/product-requirements-document-template.md`
- `/docs/templates/technical-design-document-template.md`

## Common Pitfalls

### Pitfall 1: API Without Clear Use Cases
**Bad:** "Build a user CRUD API" (no context on why/how it's used)
**Good:** "Build user API so mobile app can display profile, update settings, and change password"
**AI should flag:** "This API spec doesn't include developer use cases. Add example scenarios with code snippets."

### Pitfall 2: Breaking Changes Without Migration Plan
**Bad:** Deploying breaking API changes without notice
**Good:** API versioning, deprecation warnings, 6-month migration period
**AI should flag:** "This API change removes a field from the response. This breaks backward compatibility. Provide migration guide or use API versioning."

### Pitfall 3: Unclear Error Responses
**Bad:** Generic errors like "Invalid request" with no details
**Good:** Specific error codes, clear messages, links to documentation
**AI should flag:** "API error responses lack detail. Add error codes, descriptive messages, and documentation links."

### Pitfall 4: Missing Performance Requirements
**Bad:** No specified latency or throughput SLAs
**Good:** "P95 latency < 200ms, support 10,000 requests/minute"
**AI should flag:** "This API PRD doesn't specify performance requirements. Define latency and throughput SLAs."

## Example Interactions

### Example 1: Technical PRD Review

**TPM:** "Review this PRD for new search API."

**AI Response:**
```
**PRD Review: Search API**

✅ **Strengths:**
- Clear problem statement (current search is slow, limited)
- API specification included
- Success metrics defined (adoption, query latency)

⚠️ **Issues to Address:**

**REQUIRED (Block Approval):**

1. **Missing Authentication Specification**
   - How do developers authenticate? (API key, OAuth, JWT?)
   - Where is auth token passed? (header, query param?)
   - Fix: Add authentication section to API spec

2. **Incomplete Error Handling**
   - Only shows 200 success response
   - What about 400 (bad query), 429 (rate limit), 500 (server error)?
   - Fix: Document all error codes with examples

3. **No Rate Limiting Specified**
   - Unlimited queries per developer?
   - Fix: Define rate limits (e.g., 100 queries/minute per API key)

4. **Missing Backward Compatibility Strategy**
   - How will future changes be handled?
   - Fix: Add API versioning approach (URL versioning: /v1/search)

**RECOMMENDED (Should Include):**

5. **Developer Experience:**
   - No code examples in PRD
   - Recommendation: Add code snippets in 3 languages (JavaScript, Python, cURL)

6. **Performance Requirements Vague:**
   - "Fast search" is not measurable
   - Recommendation: Specify "P95 latency < 200ms for 90% of queries"

7. **Missing Monitoring:**
   - How will API health be tracked?
   - Recommendation: Add monitoring section (error rates, latency, usage metrics)

**OpenAPI Spec Issues:**
```yaml
# Current spec missing:
- Security schemes
- Rate limiting (x-ratelimit- headers)
- Pagination parameters (page, limit)
- Sort parameters
- Filter syntax
```

📋 **Required Actions Before Engineering:**
- [ ] Add authentication specification
- [ ] Document all error responses
- [ ] Define rate limiting
- [ ] Specify API versioning approach
- [ ] Add code examples
- [ ] Quantify performance requirements

**Recommendation:** Address required items before sharing with engineering. Should I draft the missing sections?
```

### Example 2: API Backward Compatibility Analysis

**TPM:** "We want to change the user API response format. Will this break existing integrations?"

**AI Response:**
```
**Backward Compatibility Analysis: User API Changes**

📋 **Proposed Changes:**
```json
// Current response (v1):
{
  "user_id": "123",
  "name": "John Doe",
  "email": "john@example.com"
}

// Proposed response:
{
  "id": "123",              // ❌ BREAKING: field renamed
  "fullName": "John Doe",    // ❌ BREAKING: field renamed
  "email": "john@example.com",
  "profile": {               // ✅ ADDITIVE: new nested structure
    "avatar": "url",
    "bio": "..."
  }
}
```

⚠️ **Breaking Changes Identified:**
- `user_id` → `id` (renamed)
- `name` → `fullName` (renamed)

📊 **Impact Assessment:**
- **API Consumers:** 47 applications
- **API Calls:** 2.5M calls/day
- **Migration Effort:** Each team needs to update code + deploy

🚫 **Risk:** High - this will break all 47 integrations immediately

💡 **Recommended Approaches:**

**Option 1: API Versioning (Recommended)**
```
/api/v1/users → Keep current response (no changes)
/api/v2/users → New response format
```
- ✅ No breaking changes for existing users
- ✅ New integrations use v2
- ⚠️ Requires maintaining both versions (sunset v1 in 12 months)

**Option 2: Additive-Only Changes**
```json
{
  "user_id": "123",         // Keep old field
  "id": "123",              // Add new field
  "name": "John Doe",       // Keep old field
  "fullName": "John Doe",   // Add new field
  "email": "john@example.com",
  "profile": { ... }
}
```
- ✅ No breaking changes
- ⚠️ Duplicate fields (confusing for developers)
- Deprecate old fields after 6 months

**Option 3: Breaking Change + Migration Period**
- Announce deprecation: Warn developers (email, docs, API response headers)
- Migration period: 6 months
- Provide migration guide with code examples
- ⚠️ Requires all 47 teams to migrate (high coordination)

**Recommendation: Option 1 (API Versioning)**
- Deploy /api/v2/users with new format
- Keep /api/v1/users unchanged
- Migrate teams gradually to v2
- Sunset v1 in 12 months (after all teams migrate)

**Migration Plan:**
1. **Month 1-2:** Build and test v2 API
2. **Month 3:** Launch v2, announce v1 deprecation (12-month timeline)
3. **Month 4-12:** Support teams migrating to v2
4. **Month 13:** Analyze v1 usage (should be near zero)
5. **Month 14:** Sunset v1 API

Should I draft the migration guide and developer communication?
```

## Success Metrics for AI Collaboration

- Technical PRDs complete with API specifications (100%)
- Developer documentation accompanies all API releases
- API adoption meeting targets (unique developers, API calls)
- API performance meeting SLAs (latency, error rates)
- Developer satisfaction high (survey scores, support tickets)
- Backward compatibility maintained (or proper versioning used)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Product Organization
