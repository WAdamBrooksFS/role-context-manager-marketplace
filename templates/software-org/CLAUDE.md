# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an organizational template repository demonstrating hierarchical structures for software development projects. It serves as a framework to organize systems, products, and projects within a software organization.

**Note**: This is a structure-only template with no executable code, build scripts, or test suites. It provides organizational patterns to be duplicated and populated with actual projects.

## Directory Structure

The repository follows a three-tier organizational hierarchy:

```
software-org-template/
└── system-template/
    ├── product-full-stack-template/
    │   ├── project-a-template/
    │   ├── project-b-template/
    │   └── project-test-template/
    └── product-subdivided-template/
        ├── project-backend-template/
        └── project-frontend-template/
```

### Organizational Hierarchy

1. **System Level** (`system-template/`): Top-level organizational unit representing different business systems, major initiatives, or service domains
2. **Product Level**: Mid-level grouping for related projects under a system
3. **Project Level**: Individual project directories where actual code repositories reside

### Product Organization Patterns

This template demonstrates two common product organization approaches:

**Full-Stack Products** (`product-full-stack-template/`):
- Contains multiple independent full-stack projects
- Each project is a complete application with both frontend and backend
- Suitable for microservices, separate applications, or testing environments

**Subdivided Products** (`product-subdivided-template/`):
- Separates frontend and backend into distinct projects
- Frontend and backend are deployed and versioned independently
- Suitable for large applications with separate team ownership

## Usage Pattern

When adapting this template:

- **Adding systems**: Create new directories at the `system-template` level
- **Adding products**: Create new directories under the appropriate system, choosing between full-stack or subdivided patterns
- **Adding projects**: Create new directories under the appropriate product for individual codebases

The "template" naming convention indicates placeholder directories to be renamed based on actual system/product/project names.

## Documentation System

This repository implements a comprehensive documentation framework enabling effective human-AI collaboration at every organizational level.

### Master Guide

**Start here:** `docs/document-standards-guide.md`

This guide explains:
- What documents exist at each organizational level
- When to use each document type
- How to collaborate with AI on documentation
- Document structure standards

### Document Types by Level

**Company Level (`/`):**
- Strategic direction: `objectives-and-key-results.md`, `strategy.md`, `roadmap.md`, `product-vision.md`
- Standards: `engineering-standards.md`, `quality-standards.md`, `security-policy.md`
- Organizational: `roles-and-responsibilities.md`
- Templates: `docs/templates/` (PRD, RFC, ADR, Test Plan templates)

**System Level (`system-template/`):**
- `objectives-and-key-results.md` - System OKRs supporting company OKRs
- `roadmap.md` - System-level initiatives
- `docs/architecture-decision-records/` - System-wide technical decisions

**Product Level (`product-*-template/`):**
- `roadmap.md` - Product features and timeline
- `product-overview.md` - Product description
- `docs/product-requirements-documents/` - Feature requirements (PRDs)
- `docs/release-notes.md` - Product releases

**Project Level (`project-*-template/`):**
- `contributing.md` - How to contribute code
- `development-setup.md` - Local environment setup
- `docs/technical-design-document.md` - System design
- `docs/api-documentation.md` - API reference
- `docs/architecture-decision-records/` - Project decisions
- `docs/operational-runbook.md` - Operations guide

### AI Collaboration Guides

**Role Guides** (`.claude/role-guides/`):
Each role has a guide defining how AI should assist:
- What deterministic behaviors AI must follow
- What proactive suggestions AI should make
- Common workflows and examples

**Document Guides** (`.claude/document-guides/`):
Each document type has a workflow guide:
- How to create the document
- What validation rules apply
- Cross-references to related documents

### How Information Flows

```
Company Strategy & OKRs (Why we exist, what we're achieving)
    ↓
System OKRs (How this system contributes)
    ↓
Product Roadmap (What features we're building)
    ↓
PRDs (Detailed requirements for each feature)
    ↓
Technical Designs (How we'll build it)
    ↓
Code & Tests (Implementation)
```

### Key Principles

1. **Single Source of Truth**: Each fact lives in exactly one place
2. **Living vs Static**: Documents marked with update frequency
3. **AI-Enabled**: Inline LLM instructions + companion guides
4. **Role-Based**: Documentation at the level where work happens

### Getting Started

**For new team members:**
1. Read `docs/document-standards-guide.md`
2. Find your role in `roles-and-responsibilities.md`
3. Read your role guide: `.claude/role-guides/[your-role]-guide.md`
4. Review standards relevant to your work

**For AI assistants:**
- Read document guides before creating/updating documents
- Follow role guides when assisting specific roles
- Enforce standards automatically
- Make proactive suggestions to improve quality

## Configuration

- `.claude/`: Contains Claude Code configuration and AI collaboration guides at each level
- Each directory level has its own `CLAUDE.md` documenting level-specific context
- Role guides and document guides enable deterministic and agentic AI behavior
