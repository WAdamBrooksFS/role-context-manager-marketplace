# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

This is currently an empty template directory at the **Project level**. It is specifically designated as a **testing/staging environment project**.

## Project Purpose

Unlike production application projects, this project serves as a dedicated testing or staging environment. Common use cases include:

- **Integration Testing Environment**: A complete application instance for running integration and end-to-end tests
- **Staging Environment**: A production-like environment for final validation before deployment
- **QA Environment**: A dedicated space for quality assurance testing
- **Demo Environment**: A stable environment for demonstrations or user acceptance testing

## Project Type

This project follows the **full-stack** pattern where frontend and backend code coexist in the same codebase, mirroring the structure of production projects it supports.

## When Populated, Update This File With

### 1. Build and Development Commands

Document essential commands for:
- Installing dependencies
- Starting the test/staging server(s)
- Deploying to staging infrastructure
- Running test suites (integration, e2e, smoke tests)
- Seeding test data
- Resetting/refreshing the environment

### 2. Architecture Overview

Describe the high-level structure:
- How this environment mirrors production architecture
- Test data management and seeding strategies
- Differences from production configuration (if any)
- Integration with CI/CD pipelines
- Monitoring and logging specific to test environments

### 3. Testing and Environment-Specific Conventions

Document conventions unique to this testing project:
- Test data management procedures
- Environment refresh/reset procedures
- Access control and credentials management for testing
- Integration with automated test runners
- Promotion process from this environment to production

## Organizational Context

- **System**: `system-template`
- **Product**: `product-full-stack-template`
- **Project**: `project-test-template` (current level)

This is a specialized testing/staging project within the product, separate from production projects. See `../CLAUDE.md` for product-level context.
