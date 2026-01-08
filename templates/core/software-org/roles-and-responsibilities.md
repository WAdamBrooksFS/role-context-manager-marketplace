# Roles and Responsibilities

<!-- LLM: Use this document to understand who is responsible for what. When reviewing documents or suggesting work, ensure it's assigned to the appropriate role. Help route questions and decisions to the right people based on these role definitions. -->

**Status:** Living | **Update Frequency:** Quarterly
**Primary Roles:** CEO, All Leadership, HR, All Employees
**Related Documents:** `/hiring-practices.md`, `.claude/role-guides/*.md`

## Purpose

This document defines all roles in the organization, their responsibilities, required skills, and how they interact with AI assistants. Each role has a corresponding detailed guide in `.claude/role-guides/[role]-guide.md`.

---

## Executive Leadership

### CEO (Chief Executive Officer)
**Reports to:** Board of Directors
**Primary Responsibilities:**
- Set company vision, mission, and strategy
- Lead executive team
- Manage board and investor relations
- Ultimate accountability for company success

**Works with AI for:**
- Strategic document review (OKRs, strategy, roadmap)
- Market research and competitive analysis
- Executive communications drafting

**Role Guide:** `/.claude/role-guides/ceo-guide.md`

---

## Technology Organization

### CTO / VP of Engineering
**Reports to:** CEO
**Primary Responsibilities:**
- Define technical vision and strategy
- Build and lead engineering organization
- Own engineering standards, architecture decisions
- Ensure technical scalability and reliability

**Works with AI for:**
- Technical strategy development
- Architecture decision reviews
- Engineering standards documentation
- Technical hiring assessments

**Role Guide:** `/.claude/role-guides/cto-vp-engineering-guide.md`

### Engineering Manager / Director / VP
**Reports to:** CTO/VP Engineering
**Organizational Level:** System
**Primary Responsibilities:**
- Manage engineering team (5-10 engineers typically)
- Sprint planning and execution
- Performance management and career development
- Cross-team coordination
- Technical and project decisions at system level

**Works with AI for:**
- Sprint planning and estimation
- Technical design review
- Team metrics analysis
- Documentation of system architecture

**Role Guide:** `system-template/.claude/role-guides/engineering-manager-guide.md`

---

## Software Engineering Roles

### Software Engineer (Frontend / Web)
**Reports to:** Engineering Manager
**Organizational Level:** Project
**Primary Responsibilities:**
- Build and maintain frontend user interfaces
- Implement responsive designs
- Optimize web performance
- Write frontend tests (unit, integration, E2E)

**Key Skills:** HTML, CSS, JavaScript/TypeScript, React/Vue/Angular, Testing frameworks

**Works with AI for:**
- Code implementation and review
- Test writing and debugging
- Documentation generation
- Component design suggestions

**Role Guide:** `project-*-template/.claude/role-guides/frontend-engineer-guide.md`

### Software Engineer (Backend / Systems)
**Reports to:** Engineering Manager
**Organizational Level:** Project
**Primary Responsibilities:**
- Build and maintain backend services and APIs
- Design database schemas
- Implement business logic
- Write backend tests (unit, integration, API tests)

**Key Skills:** Backend languages (Go, Python, Java, etc.), Databases (SQL, NoSQL), API design, System design

**Works with AI for:**
- API design and implementation
- Database query optimization
- Test coverage improvements
- Performance profiling

**Role Guide:** `project-*-template/.claude/role-guides/backend-engineer-guide.md`

### Software Engineer (Full Stack)
**Reports to:** Engineering Manager
**Organizational Level:** Project
**Primary Responsibilities:**
- Build features across frontend and backend
- Maintain full-stack applications
- Balance trade-offs between layers
- End-to-end feature ownership

**Key Skills:** Both frontend and backend skills

**Works with AI for:**
- Full-stack feature development
- Cross-layer debugging
- End-to-end test scenarios
- Architecture decisions

**Role Guide:** `project-*-template/.claude/role-guides/full-stack-engineer-guide.md`

### Mobile Engineer (iOS / Android)
**Reports to:** Engineering Manager
**Organizational Level:** Project
**Primary Responsibilities:**
- Build and maintain mobile applications
- Implement platform-specific features
- Optimize app performance and battery usage
- Handle app store submissions

**Key Skills:** Swift/Kotlin, Mobile UI frameworks, Platform APIs, Mobile testing

**Works with AI for:**
- Mobile-specific feature implementation
- Platform compatibility checks
- Mobile UI/UX suggestions
- Performance optimization

**Role Guide:** `project-*-template/.claude/role-guides/mobile-engineer-guide.md`

---

## Quality Assurance Organization

### Director of Quality Assurance
**Reports to:** CTO/VP Engineering
**Primary Responsibilities:**
- Define quality standards and testing strategy
- Build and lead QA organization
- Own quality metrics and continuous improvement
- Coordinate quality across all products

**Works with AI for:**
- Test strategy development
- Quality metrics analysis
- Process improvement recommendations
- Risk assessment

**Role Guide:** `/.claude/role-guides/director-qa-guide.md`

### QA Manager
**Reports to:** Director of QA
**Organizational Level:** Product
**Primary Responsibilities:**
- Manage QA team for specific product(s)
- Create product test strategies
- Coordinate testing across projects
- Quality sign-off for releases

**Works with AI for:**
- Test plan creation and review
- Coverage analysis
- Bug trend analysis
- Test case generation

**Role Guide:** `product-*-template/.claude/role-guides/qa-manager-guide.md`

### SDET (Software Development Engineer in Test)
**Reports to:** QA Manager
**Organizational Level:** Project
**Primary Responsibilities:**
- Build test automation frameworks
- Write automated tests (unit, integration, E2E)
- Maintain CI/CD test pipelines
- Code quality tooling

**Key Skills:** Programming, Testing frameworks, CI/CD, Test architecture

**Works with AI for:**
- Test automation code generation
- Framework design suggestions
- Flaky test debugging
- Coverage gap identification

**Role Guide:** `project-*-template/.claude/role-guides/sdet-guide.md`

### QA Engineer (Manual Testing)
**Reports to:** QA Manager
**Organizational Level:** Project
**Primary Responsibilities:**
- Execute manual test cases
- Exploratory testing
- Bug reporting and verification
- User acceptance testing support

**Key Skills:** Test case design, Bug reporting, Domain knowledge, Exploratory testing

**Works with AI for:**
- Test case generation from requirements
- Bug report drafting
- Regression test planning
- Exploratory test ideas

**Role Guide:** `project-*-template/.claude/role-guides/qa-engineer-guide.md`

---

## Infrastructure & Reliability

### Cloud Architect
**Reports to:** CTO/VP Engineering
**Organizational Level:** Company
**Primary Responsibilities:**
- Design cloud infrastructure architecture
- Define infrastructure standards
- Multi-cloud strategy (if applicable)
- Cost optimization

**Works with AI for:**
- Architecture decision records
- Infrastructure design review
- Cost analysis and optimization
- Technology evaluation

**Role Guide:** `/.claude/role-guides/cloud-architect-guide.md`

### Platform Engineer
**Reports to:** Engineering Manager (Infrastructure)
**Organizational Level:** System
**Primary Responsibilities:**
- Build and maintain internal platforms
- Developer tooling and productivity
- CI/CD pipelines
- Kubernetes/container orchestration

**Works with AI for:**
- Platform feature development
- Pipeline optimization
- Documentation generation
- Troubleshooting automation

**Role Guide:** `system-template/.claude/role-guides/platform-engineer-guide.md`

### DevOps Engineer
**Reports to:** Engineering Manager (Infrastructure)
**Organizational Level:** Project
**Primary Responsibilities:**
- Deploy and operate services
- Infrastructure as code (Terraform, etc.)
- Monitoring and alerting
- Incident response

**Key Skills:** Cloud platforms (AWS/GCP/Azure), IaC, Monitoring, Scripting

**Works with AI for:**
- IaC code generation and review
- Runbook creation
- Incident analysis
- Automation scripting

**Role Guide:** `project-*-template/.claude/role-guides/devops-engineer-guide.md`

### SRE (Site Reliability Engineer)
**Reports to:** Engineering Manager (Infrastructure)
**Organizational Level:** Project
**Primary Responsibilities:**
- Ensure service reliability and uptime
- Incident response and post-mortems
- Capacity planning
- SLA/SLO definition and monitoring

**Key Skills:** System administration, Monitoring, Automation, Performance tuning

**Works with AI for:**
- Post-mortem analysis
- SLO/SLI definition
- Capacity modeling
- Alert rule optimization

**Role Guide:** `project-*-template/.claude/role-guides/sre-guide.md`

---

## Data & Analytics

### Data Engineer
**Reports to:** Engineering Manager (Data)
**Organizational Level:** System
**Primary Responsibilities:**
- Build data pipelines (ETL/ELT)
- Maintain data warehouse
- Data quality and governance
- Pipeline monitoring

**Key Skills:** SQL, Python, Data tools (Airflow, dbt, etc.), Data warehouses

**Works with AI for:**
- Pipeline development and optimization
- Data transformation logic
- Data quality checks
- Documentation generation

**Role Guide:** `system-template/.claude/role-guides/data-engineer-guide.md`

### Data Scientist
**Reports to:** Director of Data Science
**Organizational Level:** Project
**Primary Responsibilities:**
- Build predictive models
- Statistical analysis
- Experiment design and analysis
- Model deployment

**Key Skills:** Statistics, ML algorithms, Python/R, Model evaluation

**Works with AI for:**
- Feature engineering ideas
- Model selection guidance
- Code implementation
- Documentation

**Role Guide:** `project-*-template/.claude/role-guides/data-scientist-guide.md`

### Data Analyst
**Reports to:** Manager (varies by team)
**Organizational Level:** Project
**Primary Responsibilities:**
- Ad-hoc data analysis
- Dashboard creation
- Report generation
- Metric definition

**Key Skills:** SQL, BI tools (Looker, Tableau), Data visualization, Statistics

**Works with AI for:**
- SQL query generation
- Dashboard design suggestions
- Insight identification
- Report drafting

**Role Guide:** `project-*-template/.claude/role-guides/data-analyst-guide.md`

---

## Security

### CISO (Chief Information Security Officer)
**Reports to:** CEO
**Primary Responsibilities:**
- Define security strategy and policies
- Manage security team
- Compliance and audit coordination
- Incident response leadership

**Works with AI for:**
- Policy development
- Threat assessment
- Compliance documentation
- Security training content

**Role Guide:** `/.claude/role-guides/ciso-guide.md`

### Security Engineer
**Reports to:** CISO
**Organizational Level:** System
**Primary Responsibilities:**
- Implement security controls
- Security testing (pen testing, SAST/DAST)
- Vulnerability management
- Security tooling

**Key Skills:** Security testing, Cryptography, Network security, Compliance

**Works with AI for:**
- Security test automation
- Vulnerability analysis
- Security documentation
- Threat modeling

**Role Guide:** `system-template/.claude/role-guides/security-engineer-guide.md`

### Compliance Officer
**Reports to:** CISO or CFO
**Primary Responsibilities:**
- Ensure regulatory compliance (GDPR, SOC2, HIPAA, etc.)
- Coordinate audits
- Policy documentation
- Training programs

**Works with AI for:**
- Compliance documentation
- Audit preparation
- Control mapping
- Policy updates

**Role Guide:** `/.claude/role-guides/compliance-officer-guide.md`

---

## Product Organization

### CPO / VP of Product
**Reports to:** CEO
**Primary Responsibilities:**
- Define product vision and strategy
- Lead product organization
- Own product roadmap
- Customer insights and market research

**Works with AI for:**
- Product strategy development
- Competitive analysis
- PRD review and feedback
- Roadmap planning

**Role Guide:** `/.claude/role-guides/cpo-vp-product-guide.md`

### Product Manager (PM)
**Reports to:** VP of Product or Group PM
**Organizational Level:** Product
**Primary Responsibilities:**
- Define product requirements (PRDs)
- Prioritize features
- Work with engineering on technical tradeoffs
- Customer research and validation

**Key Skills:** Requirements writing, Prioritization, Stakeholder management, Data analysis

**Works with AI for:**
- PRD drafting and refinement
- User story creation
- Acceptance criteria definition
- Competitive feature analysis

**Role Guide:** `product-*-template/.claude/role-guides/product-manager-guide.md`

### Technical Product Manager (TPM)
**Reports to:** VP of Product
**Organizational Level:** Product/System
**Primary Responsibilities:**
- Technical product requirements
- API and platform products
- Developer experience
- Technical feasibility assessment

**Key Skills:** Technical background, API design, Developer empathy

**Works with AI for:**
- Technical PRD development
- API design documentation
- Developer documentation
- Technical feasibility analysis

**Role Guide:** `product-*-template/.claude/role-guides/technical-product-manager-guide.md`

---

## Design

### UX Designer
**Reports to:** Design Manager or VP of Product
**Organizational Level:** Product
**Primary Responsibilities:**
- User research
- User flows and wireframes
- Interaction design
- Usability testing

**Key Skills:** User research, Wireframing, Prototyping, Usability testing

**Works with AI for:**
- User flow generation
- Research synthesis
- Documentation
- Design critique

**Role Guide:** `product-*-template/.claude/role-guides/ux-designer-guide.md`

### UI Designer
**Reports to:** Design Manager or VP of Product
**Organizational Level:** Product
**Primary Responsibilities:**
- Visual design
- Design system maintenance
- High-fidelity mockups
- Design specifications for engineering

**Key Skills:** Visual design, Design systems, Figma/Sketch, CSS

**Works with AI for:**
- Design spec generation
- Component documentation
- Accessibility checks
- Design system updates

**Role Guide:** `product-*-template/.claude/role-guides/ui-designer-guide.md`

---

## Program Management

### Technical Program Manager (TPM)
**Reports to:** VP of Engineering or VP of Product
**Organizational Level:** System
**Primary Responsibilities:**
- Coordinate cross-team initiatives
- Program roadmap and milestones
- Risk management
- Stakeholder communication

**Key Skills:** Project management, Technical understanding, Communication, Risk management

**Works with AI for:**
- Program plan development
- Dependency mapping
- Status report generation
- Risk assessment

**Role Guide:** `system-template/.claude/role-guides/technical-program-manager-guide.md`

### Scrum Master / Agile Coach
**Reports to:** Engineering Manager or PMO
**Organizational Level:** Project/Team
**Primary Responsibilities:**
- Facilitate agile ceremonies
- Remove blockers
- Team process improvement
- Agile coaching

**Key Skills:** Agile methodologies, Facilitation, Coaching, Metrics

**Works with AI for:**
- Retrospective facilitation
- Metrics analysis
- Process documentation
- Improvement suggestions

**Role Guide:** `project-*-template/.claude/role-guides/scrum-master-guide.md`

---

## Customer-Facing Roles

### Solutions Engineer / Sales Engineer
**Reports to:** VP of Sales or CRO
**Organizational Level:** Company
**Primary Responsibilities:**
- Technical pre-sales support
- Product demonstrations
- Proof of concept (POC) development
- Technical objection handling

**Works with AI for:**
- Demo script preparation
- Technical documentation for prospects
- POC code generation
- FAQ answers

**Role Guide:** `/.claude/role-guides/solutions-engineer-guide.md`

### Customer Success Manager (CSM)
**Reports to:** VP of Customer Success
**Organizational Level:** Product
**Primary Responsibilities:**
- Customer onboarding
- Relationship management
- Renewal and expansion
- Customer health monitoring

**Works with AI for:**
- Onboarding documentation
- Success plans
- Health score analysis
- Communication drafting

**Role Guide:** `product-*-template/.claude/role-guides/customer-success-manager-guide.md`

### Technical Support Engineer
**Reports to:** Support Manager
**Organizational Level:** Product
**Primary Responsibilities:**
- Troubleshoot customer issues
- Bug reproduction and escalation
- Knowledge base maintenance
- Customer communication

**Works with AI for:**
- Troubleshooting guidance
- Knowledge base article writing
- Bug report creation
- Solution documentation

**Role Guide:** `product-*-template/.claude/role-guides/technical-support-engineer-guide.md`

---

## Role Interaction Matrix

| Role | Primary Documents Created | Primary Documents Consumed | Key Stakeholders |
|------|--------------------------|---------------------------|------------------|
| CTO/VP Eng | Engineering standards, Technical strategy | OKRs, Strategy, Roadmap | CEO, CPO, Engineering Managers |
| Engineering Manager | System architecture, Team plans | Company roadmap, Product roadmaps | Engineers, Product Managers, TPMs |
| Software Engineer | Code, Tests, Technical designs, RFCs | PRDs, Technical designs, Engineering standards | Engineering Manager, QA, Product |
| Product Manager | PRDs, Roadmaps, User stories | Strategy, OKRs, User research | Engineering, Design, Customers |
| QA Engineer | Test plans, Bug reports, Test cases | PRDs, Technical designs, Release notes | Engineers, Product Managers |
| DevOps Engineer | Runbooks, Infrastructure code, Deployment docs | Architecture designs, Security policies | Engineers, SRE, Security |

---

## Career Progression

Each role has typical career progression paths. See `/hiring-practices.md` for leveling framework.

**Engineering Individual Contributor Track:**
Junior Engineer → Engineer → Senior Engineer → Staff Engineer → Principal Engineer → Distinguished Engineer

**Engineering Management Track:**
Engineer → Senior Engineer → Engineering Manager → Senior Engineering Manager → Director → VP → CTO

---

**Last Updated:** [Date]
**Next Review:** [Date]
**Document Owner:** [CEO + HR]

<!-- LLM: When users ask "who should do X" or "who owns Y", reference this document. Each role has a detailed guide in .claude/role-guides/ - direct users there for role-specific AI collaboration guidance. -->
