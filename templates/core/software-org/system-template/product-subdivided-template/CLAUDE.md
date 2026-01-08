# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Product Level Overview

This is a **Product-level** directory demonstrating the **Subdivided Product** organizational pattern. This product separates frontend and backend concerns into distinct, independently managed projects.

## Directory Structure

```
product-subdivided-template/
├── project-backend-template/     # Backend services, APIs, data layer
└── project-frontend-template/    # UI, client-side application
```

## Architectural Pattern

This product follows the **frontend/backend separation** pattern where:

- **Independent deployment**: Frontend and backend are built, tested, and deployed separately
- **Independent versioning**: Each project maintains its own version and release cycle
- **Clear separation of concerns**: Frontend handles UI/UX, backend handles business logic and data
- **Team ownership**: Different teams can own and operate frontend vs backend independently
- **Technology independence**: Frontend and backend can use different tech stacks without constraint

## Use Cases for This Pattern

This organizational structure is appropriate when:

1. **Scale and Complexity**: The application is large enough that frontend and backend need separate teams
2. **Independent Release Cycles**: Frontend and backend need to be deployed at different cadences
3. **Different Technology Stacks**: Frontend uses modern web frameworks while backend uses different languages/frameworks
4. **Microservices Integration**: Backend is part of a microservices architecture consumed by multiple frontends
5. **Team Structure**: Dedicated frontend and backend teams with different skill sets and responsibilities

## Cross-Project Considerations

When working across frontend and backend projects:

- **API Contracts**: Maintain clear API contracts/specifications between frontend and backend (OpenAPI, GraphQL schema, etc.)
- **Shared Types**: Consider how to share type definitions or contracts between projects
- **Integration Testing**: Plan for integration tests that span both projects
- **Version Compatibility**: Document version compatibility between frontend and backend releases

## Organizational Context

- **System**: `system-template` (parent directory)
- **Product**: `product-subdivided-template` (current level)
- **Projects**: Two specialized projects (frontend and backend)

Refer to `../CLAUDE.md` for system-level context and `/CLAUDE.md` for overall repository structure.
