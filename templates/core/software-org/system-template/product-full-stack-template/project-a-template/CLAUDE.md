# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

This is currently an empty template directory at the **Project level**. It is intended to contain a full-stack application with both frontend and backend components.

## Project Type

This project follows the **full-stack** pattern where frontend and backend code coexist in the same codebase. This could be structured as:

- **Monolithic full-stack**: Single application serving both UI and API
- **Monorepo**: Separate frontend and backend packages/modules within one repository
- **Framework-based**: Using full-stack frameworks (Next.js, SvelteKit, Remix, etc.)

## When Populated, Update This File With

### 1. Build and Development Commands

Document essential commands for:
- Installing dependencies
- Starting development server(s)
- Building for production
- Running tests (unit, integration, e2e)
- Running linters and formatters
- Database migrations (if applicable)

### 2. Architecture Overview

Describe the high-level structure:
- Frontend framework/library and architecture patterns
- Backend framework and API design (REST, GraphQL, etc.)
- Database and data persistence approach
- Authentication and authorization patterns
- Key third-party integrations

### 3. Project-Specific Conventions

Document conventions unique to this project:
- Directory structure and module organization
- Naming conventions for files and components
- Testing strategies and patterns
- Code review requirements

## Organizational Context

- **System**: `system-template`
- **Product**: `product-full-stack-template`
- **Project**: `project-a-template` (current level)

This is one of multiple independent projects within the product. See `../CLAUDE.md` for product-level context.
