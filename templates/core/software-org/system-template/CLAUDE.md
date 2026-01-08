# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Level Overview

This is a **System-level** directory in the organizational template hierarchy. It represents a top-level organizational unit that could correspond to a business system, major initiative, service domain, or platform within a software organization.

## Directory Structure

This system contains two product templates demonstrating different architectural patterns:

```
system-template/
├── product-full-stack-template/      # Pattern 1: Multiple independent full-stack projects
│   ├── project-a-template/
│   ├── project-b-template/
│   └── project-test-template/
└── product-subdivided-template/      # Pattern 2: Frontend/Backend separation
    ├── project-backend-template/
    └── project-frontend-template/
```

## Product Organization Patterns

### Full-Stack Product Template
Contains multiple independent projects, each being a complete application. Use this pattern when:
- Building microservices that each contain their own frontend and backend
- Managing multiple separate applications under one product umbrella
- Maintaining separate testing or staging environments as distinct projects

### Subdivided Product Template
Separates frontend and backend concerns into distinct projects. Use this pattern when:
- Frontend and backend are deployed independently
- Different teams own frontend vs backend
- You need independent versioning and release cycles for frontend and backend
- The application scale requires architectural separation

## Working at This Level

When working in this system directory:
- Each product subdirectory has its own `CLAUDE.md` with product-specific guidance
- Each project subdirectory (when populated) will have project-specific `CLAUDE.md` files
- Choose the appropriate product pattern when adding new products to this system
- Refer to `/CLAUDE.md` (root) for overall repository structure and conventions
