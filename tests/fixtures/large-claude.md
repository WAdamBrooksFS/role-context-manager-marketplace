# CLAUDE.md - Comprehensive Test Fixture

This file provides detailed guidance to Claude Code for working with this project. It serves as a test fixture for large CLAUDE.md files (≥100 lines) in the preservation testing suite.

## Repository Purpose

This is a test fixture repository for validating CLAUDE.md preservation functionality. It demonstrates a comprehensive CLAUDE.md structure with multiple sections, detailed content, and extensive documentation.

**Primary Goals**:
- Test detection of large CLAUDE.md files
- Validate adaptive suggestion generation (should produce 5-7 detailed suggestions)
- Ensure preservation during template application
- Verify enhancement workflow with comprehensive files

## Mission

Our mission is to provide reliable, well-tested CLAUDE.md preservation functionality that:
- Automatically detects existing CLAUDE.md files before template application
- Preserves user content and prevents overwrites
- Generates intelligent, context-aware enhancement suggestions
- Adapts recommendation depth based on file size and completeness

### Success Criteria

- 100% detection rate for CLAUDE.md files (case-insensitive)
- Zero unintended overwrites during template application
- Relevant suggestions generated for all preserved files
- High user satisfaction with enhancement recommendations

## Project Structure

```
test-project/
├── src/
│   ├── core/
│   ├── utils/
│   └── tests/
├── docs/
│   └── CLAUDE.md (this file)
├── .claude/
│   ├── role-guides/
│   ├── preferences.json
│   └── claude-md-suggestions.json
└── README.md
```

## Technology Stack

**Primary Language**: Bash 4+
**JSON Processing**: jq 1.6+
**Version Control**: Git
**Testing Framework**: Custom bash test suite
**CI/CD**: GitHub Actions

### Key Dependencies

- Bash 4.0 or higher (for modern array handling)
- jq for JSON parsing and manipulation
- find command with -iname support (case-insensitive search)
- grep with regex support

## Development Guidelines

### Code Style

- Use `set -euo pipefail` in all scripts for safety
- Prefer bash arrays over string splitting
- Use `local` for function variables
- Exit code 0 even on non-critical errors (non-blocking design)
- Log errors to stderr, output to stdout

### Testing Standards

- Write tests before implementation (TDD)
- Test both success and failure cases
- Use temporary directories for test isolation
- Clean up test artifacts
- Validate JSON output with jq
- Test case-insensitive file matching

### Documentation Requirements

- Document all functions with purpose, parameters, and return values
- Include usage examples in comments
- Maintain up-to-date README
- Add entries to CHANGELOG for all changes
- Document edge cases and error handling

## Common Workflows

### Running Tests

```bash
# Run all tests
bash tests/test-claude-md-preservation.sh

# Run with verbose output
bash tests/test-claude-md-preservation.sh -v

# Run specific test
bash tests/test-claude-md-preservation.sh test_detection_case_insensitive
```

### Analyzing CLAUDE.md Files

```bash
# Scan for CLAUDE.md files
bash scripts/claude-md-analyzer.sh --scan .

# Analyze specific file
bash scripts/claude-md-analyzer.sh --analyze ./CLAUDE.md

# Generate suggestions
bash scripts/claude-md-analyzer.sh --suggest ./CLAUDE.md software-org
```

### Applying Templates with Preservation

```bash
# Apply template (automatically preserves existing CLAUDE.md)
bash scripts/template-manager.sh apply-mode software-org standard .

# Check preservation status
cat .claude/preferences.json | jq '.preserved_claude_md'

# Review suggestions
cat .claude/claude-md-suggestions.json | jq '.enhancements[]'
```

## Error Handling

### Non-Blocking Design

All CLAUDE.md operations are designed to be non-blocking:
- Detection failures don't stop template application
- Analysis errors return empty results rather than failing
- Suggestion generation is optional and best-effort
- Missing dependencies are handled gracefully

### Error Logging

Errors are logged to stderr with descriptive messages:
- File not found errors
- JSON parsing failures
- Permission issues
- Invalid arguments

## Integration Points

### Template Manager

The `template-manager.sh` script integrates CLAUDE.md detection:
- Scans before applying template
- Skips copying template's CLAUDE.md if one exists
- Records preserved files in preferences.json
- Triggers suggestion generation

### Template Setup Assistant

The `template-setup-assistant` agent coordinates preservation:
- Informs user of detected CLAUDE.md files
- Explains preservation behavior
- Offers to generate enhancement suggestions
- Guides user through enhancement workflow

### Claude.md Enhancer

The `claude-md-enhancer` agent implements enhancements:
- Loads suggestions from .claude/claude-md-suggestions.json
- Presents prioritized improvements
- Gathers project context from user
- Implements approved enhancements
- Preserves original content and style
