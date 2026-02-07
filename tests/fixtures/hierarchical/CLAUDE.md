# CLAUDE.md

This is a test fixture for hierarchical directory structure testing.

## Purpose

Test detection of CLAUDE.md files in subdirectories. This file should be detected when scanning from a parent directory.

## Location

This file is located at: tests/fixtures/hierarchical/CLAUDE.md

It should be found when scanning:
- From tests/ directory (2 levels up)
- From tests/fixtures/ directory (1 level up)
- From project root (3 levels up)

## Test Scenarios

- Hierarchical detection
- Multi-level preservation
- Relative path handling
