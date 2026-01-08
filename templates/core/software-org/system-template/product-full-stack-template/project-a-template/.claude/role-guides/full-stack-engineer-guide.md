# Full-Stack Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build features across frontend and backend layers
**Organizational Level:** Project
**Key Documents Created:** Full-stack features, E2E tests, API + UI documentation
**Key Documents Consumed:** PRDs, technical designs, engineering standards, UI specs

## Deterministic Behaviors

### When Implementing Full-Stack Features

**AI MUST:**
- Follow frontend and backend engineering standards
- Ensure frontend-backend contract alignment (API matches UI needs)
- Include tests at all layers (unit, integration, E2E)
- Handle cross-layer concerns (authentication, error handling, loading states)
- Optimize data flow (no over-fetching, proper caching)
- Ensure security at all layers (input validation frontend + backend)

**Validation Checklist:**
- [ ] Backend API follows standards (REST/GraphQL conventions)
- [ ] Frontend UI matches design specifications
- [ ] API contract documented (request/response schemas)
- [ ] Tests at all layers (unit, integration, E2E)
- [ ] Authentication/authorization implemented
- [ ] Loading and error states in UI
- [ ] Input validation both frontend and backend
- [ ] Performance optimized (query efficiency, bundle size)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest when API design doesn't match frontend needs
- Recommend full-stack optimizations (GraphQL vs REST, caching strategy)
- Flag inconsistencies between layers (validation, error handling)
- Propose architecture improvements (separation of concerns)
- Identify cross-layer performance issues
- Suggest better end-to-end testing strategies

### Full-Stack Development Support

**AI CAN help with:**
- End-to-end feature implementation
- API + frontend integration
- Cross-layer debugging
- Architecture decision making
- Test coverage across layers
- Performance optimization (database → API → UI)
- Documentation across the stack

## Common Workflows

### Workflow 1: End-to-End Feature Implementation

```
1. Full-Stack Engineer: "Implement user profile edit feature"
2. AI: Plan full-stack approach:
   - Backend: PUT /api/users/:id endpoint
   - Database: Update user table
   - Frontend: Profile edit form component
   - Integration: API calls, state management
3. AI: Implement backend:
   - API endpoint with validation
   - Database query
   - Unit and integration tests
4. AI: Implement frontend:
   - Form component with validation
   - API integration
   - Loading/error states
   - Component tests
5. AI: Create E2E test covering full flow
6. Full-Stack Engineer: Reviews and refines
```

### Workflow 2: Debug Cross-Layer Issue

```
1. Full-Stack Engineer: "Form submission fails silently"
2. AI: Investigate across layers:
   - Frontend: Form validation passing?
   - Network: Request reaching backend?
   - Backend: Endpoint returning error?
   - Database: Query failing?
3. AI: Identify root cause:
   - Backend validation expects field "email"
   - Frontend sends field "emailAddress"
   - Contract mismatch!
4. AI: Propose fix:
   - Option A: Frontend uses "email" (match backend)
   - Option B: Backend accepts "emailAddress" (match frontend)
   - Recommendation: Fix frontend (less impact)
5. Full-Stack Engineer: Implements fix
```

## Document References

### Documents Full-Stack Engineer Creates
- `project-*/src/` (frontend + backend code)
- `project-*/docs/api-documentation.md`
- `project-*/docs/feature-documentation.md`
- `project-*/tests/` (all test types)

### Documents Full-Stack Engineer References
- `/engineering-standards.md`
- `/quality-standards.md`
- `/security-policy.md`
- `product-*/docs/product-requirements-documents/*.md`
- `project-*/docs/technical-design-document.md`
- UI design specifications

## Common Pitfalls

### Pitfall 1: Inconsistent Validation
**Bad:** Frontend validates but backend doesn't (security risk)
**Good:** Both layers validate (frontend for UX, backend for security)
**AI should flag:** "Frontend validates email but backend doesn't. Add backend validation."

### Pitfall 2: API Over-fetching
**Bad:** API returns entire user object when UI needs just name
**Good:** API returns only requested fields
**AI should flag:** "API returns 20 fields but UI uses 3. Optimize with field selection or GraphQL."

### Pitfall 3: Missing E2E Tests
**Bad:** Only unit tests, no end-to-end coverage
**Good:** E2E tests covering critical user flows
**AI should flag:** "Feature lacks E2E test. Add test covering user flow from UI to database."

## Success Metrics for AI Collaboration

- Features work end-to-end on first deployment (minimal bugs)
- Test coverage across all layers (80%+)
- API contracts clear and documented
- Cross-layer performance optimized
- Security validated at all layers

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Team
