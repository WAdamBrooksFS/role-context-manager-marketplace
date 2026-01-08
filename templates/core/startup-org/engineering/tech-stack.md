# Tech Stack

<!-- LLM: Help founders document and justify their technology choices. This prevents constant "should we switch to X?" conversations. Update when stack changes. For start-ups: boring technology is good technology - proven, documented, easy to hire for. -->

**Status:** Living | **Update Frequency:** As needed (when making significant tech changes)
**Primary Roles:** Technical Co-founder, Founding Engineers
**Related Documents:** `/engineering/architecture-overview.md`, `/engineering/development-setup.md`

## Purpose

Documents our technology choices and rationale. Helps with hiring, onboarding, and prevents endless technology debates.

**Principle:** Choose boring, proven technology unless there's a compelling reason not to. Exotic tech makes hiring harder and increases risk.

---

## Tech Stack Overview

### Frontend
- **Framework:** [e.g., React, Vue, Angular]
- **Language:** [e.g., TypeScript]
- **State Management:** [e.g., Redux, Zustand, Context]
- **Styling:** [e.g., TailwindCSS, CSS Modules]
- **Build Tool:** [e.g., Vite, Next.js, Create React App]

**Why These Choices:**
[Brief rationale for frontend stack]

### Backend
- **Language:** [e.g., Node.js, Python, Go]
- **Framework:** [e.g., Express, FastAPI, Gin]
- **API Style:** [REST, GraphQL, gRPC]

**Why These Choices:**
[Brief rationale for backend stack]

### Database
- **Primary Database:** [e.g., PostgreSQL, MySQL, MongoDB]
- **Caching:** [e.g., Redis, Memcached]
- **Search:** [e.g., Elasticsearch, Algolia] (if applicable)

**Why These Choices:**
[Brief rationale for database choices]

### Infrastructure
- **Cloud Provider:** [e.g., AWS, GCP, Azure]
- **Hosting:** [e.g., Vercel, Heroku, EC2, Cloud Run]
- **CI/CD:** [e.g., GitHub Actions, CircleCI, GitLab CI]
- **Monitoring:** [e.g., Datadog, New Relic, CloudWatch]

**Why These Choices:**
[Brief rationale for infrastructure choices]

---

## Detailed Technology Decisions

### [Technology Category]

**Current Choice:** [Technology name and version]

**Alternatives Considered:**
- [Alternative 1]: [Why we didn't choose it]
- [Alternative 2]: [Why we didn't choose it]

**Decision Rationale:**
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Trade-offs:**
- ✅ Pros: [What we gain]
- ❌ Cons: [What we lose]

**When to Reconsider:**
[Conditions that would make us revisit this decision]

---

## Complete Stack Reference

### Frontend Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Framework | [e.g., React] | [e.g., 18.x] | UI library |
| Language | [e.g., TypeScript] | [e.g., 5.x] | Type safety |
| Routing | [e.g., React Router] | [e.g., 6.x] | Client-side routing |
| State | [e.g., Zustand] | [e.g., 4.x] | State management |
| Forms | [e.g., React Hook Form] | [e.g., 7.x] | Form handling |
| Styling | [e.g., TailwindCSS] | [e.g., 3.x] | CSS framework |
| HTTP Client | [e.g., Axios] | [e.g., 1.x] | API calls |
| Testing | [e.g., Vitest] | [e.g., 1.x] | Unit tests |
| E2E Testing | [e.g., Playwright] | [e.g., 1.x] | End-to-end tests |

### Backend Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Runtime | [e.g., Node.js] | [e.g., 20.x LTS] | Server runtime |
| Framework | [e.g., Express] | [e.g., 4.x] | Web framework |
| Language | [e.g., TypeScript] | [e.g., 5.x] | Type safety |
| ORM | [e.g., Prisma] | [e.g., 5.x] | Database access |
| Validation | [e.g., Zod] | [e.g., 3.x] | Input validation |
| Auth | [e.g., JWT] | [e.g., 9.x] | Authentication |
| Testing | [e.g., Jest] | [e.g., 29.x] | Unit tests |
| API Docs | [e.g., Swagger] | [e.g., 5.x] | API documentation |

### Database & Data

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Primary DB | [e.g., PostgreSQL] | [e.g., 15.x] | Main database |
| Caching | [e.g., Redis] | [e.g., 7.x] | Cache layer |
| Queue | [e.g., BullMQ] | [e.g., 4.x] | Job queue (if needed) |
| File Storage | [e.g., S3] | - | File uploads |

### Infrastructure & DevOps

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Cloud | [e.g., AWS] | - | Infrastructure |
| Hosting | [e.g., Vercel (frontend)] | - | Frontend hosting |
| Hosting | [e.g., Railway (backend)] | - | Backend hosting |
| CI/CD | [e.g., GitHub Actions] | - | Automation |
| Monitoring | [e.g., Sentry] | - | Error tracking |
| Logging | [e.g., Better Stack] | - | Log aggregation |
| Analytics | [e.g., PostHog] | - | Product analytics |

### Development Tools

| Category | Technology | Purpose |
|----------|------------|---------|
| Version Control | Git + GitHub | Code repository |
| Package Manager | [e.g., pnpm] | Dependency management |
| IDE | [e.g., VS Code] | Development environment |
| API Testing | [e.g., Postman] | API development |
| Database GUI | [e.g., Postico, TablePlus] | Database management |

---

## Technology Principles

### 1. Boring Technology (Mostly)

**Philosophy:** Use proven, boring technology for 90% of the stack. Save innovation budget for where it matters (your product).

**Why:**
- Easier to hire (more developers know React than [exotic framework])
- Better documentation and community support
- Fewer surprises and edge cases
- Faster debugging (Stack Overflow has answers)

**Innovation Budget:**
You get ~3 "innovation tokens" to spend on new/unproven tech. Use them wisely.

### 2. TypeScript Everywhere (If Using JS/TS)

**Philosophy:** Use TypeScript for both frontend and backend.

**Why:**
- Catch bugs at compile time, not runtime
- Better IDE support (autocomplete, refactoring)
- Self-documenting code (types as documentation)
- Easier refactoring as you grow

**Trade-off:** Slightly slower initial development, but way faster iteration long-term.

### 3. Monorepo (As You Grow)

**Current:** [Single repo / Multiple repos / Monorepo]

**Philosophy:** Start simple, move to monorepo when you have 3+ related codebases.

**Why:**
- Share code easily (types, utils, components)
- Atomic commits across frontend/backend
- Easier dependency management
- Better for small teams

**Tools:** [e.g., Turborepo, Nx, or simple npm workspaces]

### 4. Managed Services Over Self-Hosting

**Philosophy:** Use managed services (SaaS) for everything except your core product.

**Examples:**
- Database: Managed PostgreSQL (RDS, Supabase) not self-hosted
- Auth: Auth0, Clerk, Supabase Auth (not custom JWT from scratch)
- Email: SendGrid, Resend (not self-hosted mail server)
- Payments: Stripe (not custom payment processing)

**Why:**
- Focus engineering time on product, not infrastructure
- Better uptime and security than you can build
- Easier to scale
- Your time is more expensive than $50/month service

---

## Key Technology Decisions

### Decision: [Technology Choice]

**Date:** [When decision was made]
**Status:** [Active / Deprecated / Under Review]

**Context:**
[What problem were you solving? What constraints did you have?]

**Decision:**
[What technology did you choose?]

**Alternatives:**
1. [Alternative 1] - [Why not]
2. [Alternative 2] - [Why not]

**Rationale:**
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Consequences:**
- ✅ Benefits: [What you gain]
- ❌ Drawbacks: [What you lose]
- ⚠️ Risks: [What could go wrong]

**Review Date:** [When to reconsider]

---

## Migration Plans (If Applicable)

### Migrating From [Old Tech] to [New Tech]

**Why We're Migrating:**
[Problem with current technology]

**Timeline:**
- **Phase 1:** [Milestone] - [Date]
- **Phase 2:** [Milestone] - [Date]
- **Complete:** [Target date]

**Risks & Mitigation:**
- **Risk:** [What could go wrong]
  - **Mitigation:** [How we're handling it]

---

## Dependencies (Key Packages)

### Critical Dependencies

**Frontend:**
```json
{
  "[package-1]": "[version]",  // [Purpose]
  "[package-2]": "[version]",  // [Purpose]
  "[package-3]": "[version]"   // [Purpose]
}
```

**Backend:**
```json
{
  "[package-1]": "[version]",  // [Purpose]
  "[package-2]": "[version]",  // [Purpose]
  "[package-3]": "[version]"   // [Purpose]
}
```

### Dependency Management

**Update Strategy:**
- Security patches: Immediately
- Minor versions: Weekly/bi-weekly
- Major versions: Quarterly (with testing)

**Tools:**
- [e.g., Dependabot for automated PRs]
- [e.g., Snyk for security scanning]

---

## When to Change Technologies

### Good Reasons to Switch
- Current tech has major security vulnerability with no fix
- Cannot meet product requirements (performance, features)
- Technology is abandoned (no updates in 2+ years)
- Blocking ability to hire or scale team

### Bad Reasons to Switch
- "New shiny framework" excitement
- Competitor uses different stack
- Hacker News said it's better
- Engineer wants to learn new tech

### Decision Framework
**Before switching, ask:**
1. What problem are we solving?
2. Can we solve it without switching?
3. What's the migration cost (time, risk, team morale)?
4. Will new tech actually solve the problem?
5. Is this the right time (or distraction from product)?

---

## Technology Evaluation Template

When considering new technology:

### [Technology Name]

**Problem It Solves:**
[What need or pain point does this address?]

**Alternatives:**
1. [Keep current solution]
2. [Other option 1]
3. [Other option 2]

**Pros:**
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

**Cons:**
- [Drawback 1]
- [Drawback 2]
- [Drawback 3]

**Adoption Criteria:**
- Community size: [npm downloads, GitHub stars, etc.]
- Maturity: [How long has it existed?]
- Maintenance: [Last update, issue response time]
- Documentation: [Quality of docs]
- Team familiarity: [Do we know this already?]
- Hiring impact: [Easy to hire for?]

**Decision:** [Adopt / Don't adopt / Experiment]

**Next Steps:**
- [Action item 1]
- [Action item 2]

---

## Resources

**Documentation:**
- [Link to key technology docs]
- [Internal architecture docs]

**Learning:**
- [Recommended tutorials]
- [Team knowledge base]

---

**Last Updated:** [Date]
**Next Review:** [When stack changes or quarterly]
**Document Owner:** Technical Co-founder

<!-- LLM: When helping with tech stack decisions, encourage boring technology. Start-ups die from product-market fit problems, not technology choices. The best stack is the one the team already knows and can ship fast with. Only use new tech if there's a compelling product reason. Ask: "Will this help us ship faster or better?" If no, stick with boring proven tech. -->
