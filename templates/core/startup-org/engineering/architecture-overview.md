# Architecture Overview

<!--LLM: Simple system design for start-ups. Avoid over-engineering. Document what exists, not ideal future state.-->

**Status:** Living | **Update Frequency:** Quarterly or after major changes
**Primary Roles:** Technical Co-founder, Senior Engineers
**Related Documents:** `/engineering/tech-stack.md`, `/engineering/engineering-standards.md`

## High-Level Architecture

[Simple diagram or description of your system components]

**Example:**
```
User Browser
     ↓
Frontend (React on Vercel)
     ↓
API Server (Node.js on Railway)
     ↓
Database (PostgreSQL on Supabase)
     ↓
File Storage (AWS S3)
```

## System Components

### Frontend
- **Technology:** [e.g., React + TypeScript]
- **Hosting:** [e.g., Vercel]
- **Purpose:** User interface and client-side logic

### Backend API
- **Technology:** [e.g., Node.js + Express]
- **Hosting:** [e.g., Railway, AWS]
- **Purpose:** Business logic, data access, authentication

### Database
- **Technology:** [e.g., PostgreSQL]
- **Hosting:** [e.g., Supabase, AWS RDS]
- **Purpose:** Persistent data storage

### Third-Party Services
- **Auth:** [e.g., Clerk, Auth0]
- **Payments:** [e.g., Stripe]
- **Email:** [e.g., SendGrid]
- **Analytics:** [e.g., PostHog]
- **Monitoring:** [e.g., Sentry]

## Data Flow

**Typical Request:**
1. User action in browser
2. API call to backend
3. Backend validates and processes
4. Database query/update
5. Response to frontend
6. UI update

## Security Architecture

**Authentication:** [How users authenticate]
**Authorization:** [How permissions work]
**Data Protection:** [Encryption, HTTPS, etc.]

## Scaling Considerations

**Current Scale:** [Users, requests/day, data size]
**Bottlenecks:** [What will break first as you grow]
**Next Steps:** [What needs to scale first]

---

**Last Updated:** [Date]
**Document Owner:** Technical Co-founder
