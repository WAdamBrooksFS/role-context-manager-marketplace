# Changelog

All notable changes to the role-context-manager plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-01-06

### Added
- **Complete Template Bundling**: Templates now include full organizational frameworks
  - software-org: 748KB with 70 files (document templates, process guides, hierarchical examples)
  - startup-org: 260KB with 19 files (fundraising docs, strategic planning, engineering practices)
- **Application Modes**: Three modes for template installation (minimal/standard/complete)
  - Minimal: `.claude/` directory only
  - Standard: `.claude/` + organizational documents
  - Complete: Everything including document templates and process guides
- **Template Content Discovery**: New functions in template-manager.sh
  - `get-content-reference`: Get path to template content for agent use
  - `list-template-contents`: Display template contents from manifest
  - `get-template-size`: Show template size and file count
  - `apply-mode`: Apply template with specific mode
- **Enhanced Manifests**: Templates now include detailed content_structure
- **Enhanced Registry**: Template metadata with size, file counts, and content inventory
- **Agent Intelligence**: Agents can now reference bundled template content
  - document-generator: Access document templates (PRD, ADR, RFC, etc.)
  - template-setup-assistant: Offer application mode selection
  - role-guide-generator: Reference template role guides as examples

### Changed
- **Template Path**: Moved from `templates/[id]` to `templates/core/[id]`
- **Template Version**: Bumped to 2.0.0 for complete content
- **record_applied_template**: Now tracks application mode in preferences
- **apply_template**: Defaults to "standard" mode for backward compatibility

### Improved
- Document-generator agent can access bundled document templates
- Template-setup-assistant presents application mode options
- Role-guide-generator can reference template role guides
- Template manager script has better content discovery

## [1.2.0] - 2026-01-05

### Added
- SessionStart Hook for automatic validation and update checks
- Hook configuration via `/setup-plugin-hooks` command
- Automatic template version checking on session start
- Validation reminders on session start

### Changed
- Updated plugin configuration to support session-start hooks
- Enhanced template synchronization with automatic checks

## [1.1.0] - 2026-01-05

### Added
- Template discovery system with registry.json
- Helper agents for setup and document generation:
  - template-setup-assistant
  - document-generator
  - role-guide-generator
  - framework-validator
  - template-sync
- New commands:
  - `/init-org-template`: Initialize organizational framework from template
  - `/generate-document`: Generate documents from templates
  - `/create-role-guide`: Create new role guides
  - `/validate-setup`: Validate .claude directory structure
  - `/sync-template`: Sync template updates
- Template management scripts and utilities

### Changed
- Enhanced README with template usage documentation
- Added TEMPLATES.md guide for template system

## [1.0.0] - 2025-12-03

### Added
- Initial release of role-context-manager plugin
- Role-based document context loading
- Commands for role management:
  - `/set-role`: Set current user role
  - `/show-role-context`: Display role and document context
  - `/update-role-docs`: Customize role document references
  - `/init-role-docs`: Initialize role-document mappings
  - `/set-org-level`: Set organizational level
- Support for organizational hierarchy (company/system/product/project)
- Role-to-document reference system
- Preference management in `.claude/preferences.json`
- Plugin scripts for role and level management

[1.3.0]: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/releases/tag/v1.0.0
