# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Product Level Overview

This is a **Product-level** directory demonstrating the **Full-Stack Product** organizational pattern. This product contains multiple independent full-stack projects, each being a self-contained application with its own frontend and backend components.

## Directory Structure

```
product-full-stack-template/
├── project-a-template/       # Independent full-stack project A
├── project-b-template/       # Independent full-stack project B
└── project-test-template/    # Testing/staging environment project
```

## Architectural Pattern

This product follows the **multiple independent projects** pattern where:

- **Each project is self-contained**: Contains both frontend and backend code
- **Independent deployment**: Each project can be built, tested, and deployed separately
- **Separate repositories possible**: Projects could be split into their own git repositories if needed
- **Different purposes**: Projects can serve different environments (production, staging, testing) or different microservices

## Use Cases for This Pattern

This organizational structure is appropriate when:

1. **Microservices Architecture**: Each project represents a different microservice with its own frontend interface
2. **Multiple Applications**: The product encompasses several distinct applications that share a common domain
3. **Environment Separation**: Separate projects for production applications vs testing/staging applications (e.g., `project-test-template`)
4. **Team Independence**: Different teams own different projects but work under the same product umbrella

## Organizational Context

- **System**: `system-template` (parent directory)
- **Product**: `product-full-stack-template` (current level)
- **Projects**: Three independent full-stack projects

Refer to `../CLAUDE.md` for system-level context and `/CLAUDE.md` for overall repository structure.
