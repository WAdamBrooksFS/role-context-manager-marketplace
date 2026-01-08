# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

This is currently an empty template directory at the **Project level**. It is designated as the **backend project** within a subdivided product architecture.

## Project Purpose

This project contains backend services, APIs, business logic, and data persistence layers. It operates independently from the frontend project but serves as the API provider for it.

## When Populated, Update This File With

### 1. Build and Development Commands

Document essential commands for:
- Installing dependencies
- Starting development server
- Building for production
- Running tests (unit, integration, API tests)
- Running database migrations
- Seeding development/test data
- Running linters and formatters

### 2. Architecture Overview

Describe the high-level backend structure:
- API design pattern (REST, GraphQL, gRPC, etc.)
- Backend framework and language
- Database and ORM/query layer
- Authentication and authorization implementation
- Middleware and request processing pipeline
- Background job processing (if applicable)
- Caching strategy
- External service integrations

### 3. API Contract Management

Document how API contracts are maintained:
- API specification location (OpenAPI/Swagger, GraphQL schema, etc.)
- Versioning strategy for APIs
- Breaking change policy
- How frontend consumes the API contract

### 4. Database Management

Document database operations:
- Migration commands and workflow
- Schema versioning approach
- Local development database setup
- Test database management

### 5. Backend-Specific Conventions

Document conventions unique to this backend:
- Code organization and module structure
- Error handling patterns
- Logging and monitoring practices
- Testing strategies and coverage requirements

## Coordination with Frontend

This backend project is paired with `../project-frontend-template/`. Key coordination points:

- **API Contracts**: Maintain shared API specifications that frontend depends on
- **Version Compatibility**: Document which frontend versions are compatible with backend versions
- **Local Development**: Document how to run frontend and backend together locally
- **Integration Testing**: Consider cross-project integration tests

## Organizational Context

- **System**: `system-template`
- **Product**: `product-subdivided-template`
- **Project**: `project-backend-template` (current level - backend)

This backend project is independently deployed from the frontend. See `../CLAUDE.md` for product-level context and coordination guidance.
