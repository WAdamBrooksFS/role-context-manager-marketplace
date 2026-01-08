# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

This is currently an empty template directory at the **Project level**. It is designated as the **frontend project** within a subdivided product architecture.

## Project Purpose

This project contains the user interface, client-side application logic, and presentation layer. It operates independently from the backend project but consumes its APIs.

## When Populated, Update This File With

### 1. Build and Development Commands

Document essential commands for:
- Installing dependencies
- Starting development server
- Building for production
- Running tests (unit, component, integration, e2e)
- Running linters and formatters
- Type checking (if using TypeScript)

### 2. Architecture Overview

Describe the high-level frontend structure:
- Frontend framework/library (React, Vue, Angular, Svelte, etc.)
- State management approach (Redux, Zustand, Pinia, NgRx, etc.)
- Routing implementation and structure
- API client configuration and usage patterns
- Component organization and design patterns
- Styling approach (CSS Modules, styled-components, Tailwind, etc.)
- Build tools and bundler configuration

### 3. API Integration

Document how frontend consumes backend APIs:
- API client setup and configuration
- Type safety for API calls (TypeScript types, code generation, etc.)
- Error handling patterns
- Authentication token management
- API versioning strategy

### 4. Frontend-Specific Conventions

Document conventions unique to this frontend:
- Component naming and file structure
- Props and state management patterns
- Testing strategies (unit, integration, visual regression)
- Accessibility requirements
- Browser support policy

### 5. Development Workflow

Document local development setup:
- Environment variables configuration
- Backend API connection (local vs staging)
- Mock/stub data for development
- Hot module replacement and dev server setup

## Coordination with Backend

This frontend project is paired with `../project-backend-template/`. Key coordination points:

- **API Contracts**: Consume API specifications from backend (OpenAPI, GraphQL schema)
- **Version Compatibility**: Document which backend versions this frontend is compatible with
- **Local Development**: Document how to connect to local backend or use staging APIs
- **Type Generation**: If using code generation from API specs, document the process

## Organizational Context

- **System**: `system-template`
- **Product**: `product-subdivided-template`
- **Project**: `project-frontend-template` (current level - frontend)

This frontend project is independently deployed from the backend. See `../CLAUDE.md` for product-level context and coordination guidance.
