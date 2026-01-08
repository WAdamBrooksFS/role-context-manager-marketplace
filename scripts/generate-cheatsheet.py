#!/usr/bin/env python3
"""
Generate a comprehensive cheatsheet PDF for the role-context-manager plugin.
This script creates an HTML document with embedded CSS and converts it to PDF using WeasyPrint.
"""

from weasyprint import HTML
import os

def generate_css():
    """Generate professional/corporate CSS styling."""
    return """
        @page {
            size: A4;
            margin: 0.75in;

            @bottom-center {
                content: "Page " counter(page) " of " counter(pages);
                font-size: 9pt;
                color: #4A5568;
            }
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 11pt;
            line-height: 1.6;
            color: #1A202C;
            background: #FFFFFF;
        }

        /* Header Styling */
        .header {
            text-align: center;
            padding: 20px 0 30px 0;
            border-bottom: 3px solid #2C5282;
            margin-bottom: 30px;
        }

        .header h1 {
            font-size: 28pt;
            color: #2C5282;
            margin-bottom: 10px;
            font-weight: 700;
        }

        .header .version {
            font-size: 12pt;
            color: #4A5568;
            margin-bottom: 8px;
        }

        .header .description {
            font-size: 11pt;
            color: #1A202C;
            font-style: italic;
        }

        /* Table of Contents */
        .toc {
            background: #F7FAFC;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border: 1px solid #E2E8F0;
        }

        .toc h2 {
            font-size: 16pt;
            color: #2C5282;
            margin-bottom: 15px;
        }

        .toc ul {
            list-style: none;
            columns: 2;
            column-gap: 30px;
        }

        .toc li {
            margin-bottom: 8px;
            break-inside: avoid;
        }

        .toc a {
            color: #3182CE;
            text-decoration: none;
            font-weight: 500;
        }

        .toc a:hover {
            text-decoration: underline;
        }

        /* Headings */
        h1 {
            font-size: 24pt;
            color: #2C5282;
            margin-top: 40px;
            margin-bottom: 20px;
            padding-top: 20px;
            border-top: 2px solid #E2E8F0;
            page-break-before: always;
        }

        h1:first-of-type {
            page-break-before: auto;
        }

        h2 {
            font-size: 18pt;
            color: #2C5282;
            margin-top: 30px;
            margin-bottom: 15px;
        }

        h3 {
            font-size: 14pt;
            color: #4A5568;
            margin-top: 20px;
            margin-bottom: 10px;
        }

        /* Phase Sections */
        .phase-section {
            padding: 20px;
            margin-bottom: 25px;
            border-radius: 8px;
            border-left: 4px solid;
            break-inside: avoid;
        }

        .phase-setup {
            background: #EBF8FF;
            border-left-color: #3182CE;
        }

        .phase-configuration {
            background: #F7FAFC;
            border-left-color: #4A5568;
        }

        .phase-daily {
            background: #F0FFF4;
            border-left-color: #38A169;
        }

        .phase-maintenance {
            background: #FFFAF0;
            border-left-color: #DD6B20;
        }

        .phase-title {
            font-size: 16pt;
            font-weight: 700;
            color: #2C5282;
            margin-bottom: 8px;
        }

        .phase-when {
            font-size: 10pt;
            color: #4A5568;
            font-style: italic;
            margin-bottom: 15px;
        }

        /* Command Styling */
        .command {
            background: #2D3748;
            color: #E2E8F0;
            padding: 3px 8px;
            border-radius: 4px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 10pt;
            white-space: nowrap;
        }

        .command-block {
            margin: 15px 0;
            break-inside: avoid;
        }

        .command-name {
            font-weight: 700;
            font-size: 12pt;
            color: #2C5282;
            margin-bottom: 5px;
        }

        .command-description {
            color: #1A202C;
            margin-bottom: 5px;
        }

        /* Agent Styling */
        .agent-block {
            margin: 15px 0;
            padding: 12px;
            background: #F7FAFC;
            border-left: 3px solid #3182CE;
            border-radius: 4px;
            break-inside: avoid;
        }

        .agent-name {
            font-weight: 700;
            font-size: 11pt;
            color: #2C5282;
            margin-bottom: 5px;
        }

        /* Tables */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 10pt;
        }

        th {
            background: #2C5282;
            color: white;
            padding: 10px;
            text-align: left;
            font-weight: 600;
        }

        td {
            padding: 8px 10px;
            border-bottom: 1px solid #E2E8F0;
        }

        tr:nth-child(even) {
            background: #F7FAFC;
        }

        /* Callout Boxes */
        .callout {
            padding: 12px 15px;
            margin: 15px 0;
            border-left: 4px solid #3182CE;
            background: #EBF8FF;
            border-radius: 4px;
            break-inside: avoid;
        }

        .callout-title {
            font-weight: 700;
            color: #2C5282;
            margin-bottom: 5px;
        }

        /* Code Blocks */
        pre {
            background: #2D3748;
            color: #E2E8F0;
            padding: 12px;
            border-radius: 4px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 9pt;
            line-height: 1.4;
            margin: 15px 0;
        }

        code {
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 9.5pt;
        }

        /* Lists */
        ul {
            margin: 10px 0;
            padding-left: 25px;
        }

        li {
            margin-bottom: 5px;
        }

        /* Scope Diagram */
        .scope-diagram {
            background: #F7FAFC;
            padding: 20px;
            border: 2px solid #E2E8F0;
            border-radius: 8px;
            font-family: monospace;
            margin: 20px 0;
            white-space: pre;
            line-height: 1.8;
            break-inside: avoid;
        }

        /* Utility Classes */
        .text-center {
            text-align: center;
        }

        .mt-large {
            margin-top: 30px;
        }

        .mb-medium {
            margin-bottom: 20px;
        }

        p {
            margin-bottom: 10px;
        }

        strong {
            color: #2C5282;
            font-weight: 600;
        }
    """

def generate_html():
    """Generate the complete HTML content for the cheatsheet."""
    css = generate_css()

    html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Role Context Manager - Cheatsheet</title>
    <style>{css}</style>
</head>
<body>
    <div class="header">
        <h1>Role Context Manager</h1>
        <div class="version">Plugin Version 1.3.0</div>
        <div class="description">Role-based document context manager for Claude Code</div>
    </div>

    <div class="toc">
        <h2>Table of Contents</h2>
        <ul>
            <li><a href="#setup">Initial Setup Phase</a></li>
            <li><a href="#configuration">Configuration Phase</a></li>
            <li><a href="#daily">Daily Usage Phase</a></li>
            <li><a href="#maintenance">Maintenance Phase</a></li>
            <li><a href="#scope">Understanding Scope</a></li>
            <li><a href="#reference">Quick Reference</a></li>
            <li><a href="#patterns">Common Patterns</a></li>
            <li><a href="#hooks">SessionStart Hook</a></li>
        </ul>
    </div>

    <h1 id="setup">Initial Setup Phase</h1>
    <p><strong>When to use:</strong> First-time user or new project initialization</p>

    <div class="phase-section phase-setup">
        <div class="phase-title">Commands</div>

        <div class="command-block">
            <div class="command-name"><span class="command">/init-org-template [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Initialize organizational framework from a template</div>
            <p><strong>What it does:</strong></p>
            <ul>
                <li>Invokes Template Setup Assistant agent</li>
                <li>Analyzes your project structure</li>
                <li>Presents available templates (software-org, startup-org)</li>
                <li>Applies chosen template to appropriate scope</li>
                <li>Records template tracking for auto-updates</li>
            </ul>
            <p><strong>Flags:</strong> <span class="command">--global</span> (apply to ~/.claude/), <span class="command">--project</span> (apply to ./.claude/)</p>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/setup-plugin-hooks [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Configure SessionStart hook for automatic validation</div>
            <p><strong>What it configures:</strong></p>
            <ul>
                <li>Adds SessionStart hook to settings.json</li>
                <li>Sets up automatic validation and update checks</li>
                <li>Creates setup marker file</li>
            </ul>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/set-role [role-name] [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Set your current role to determine which documents load</div>
            <p><strong>Parameters:</strong> role-name (required, e.g., software-engineer, product-manager)</p>
            <p><strong>What it does:</strong></p>
            <ul>
                <li>Validates role exists at current organizational level</li>
                <li>Updates preferences.json with your role</li>
                <li>Initializes role-specific document references</li>
                <li>Displays documents that will load on next session</li>
            </ul>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/set-org-level [level] [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Explicitly set organizational level</div>
            <p><strong>Levels:</strong></p>
            <ul>
                <li><strong>company</strong> - Root level (CTO, CPO, CISO, VP Engineering)</li>
                <li><strong>system</strong> - Coordination level (Engineering Manager, Platform Engineer)</li>
                <li><strong>product</strong> - Product management level (Product Manager, QA Manager, UX Designer)</li>
                <li><strong>project</strong> - Implementation level (Software Engineer, DevOps Engineer, QA Engineer)</li>
            </ul>
            <p><strong>When to use:</strong> Directory structure doesn't match standard patterns, want to override automatic detection</p>
        </div>
    </div>

    <div class="phase-section phase-setup">
        <div class="phase-title">Agent: Template Setup Assistant</div>
        <div class="agent-block">
            <div class="agent-name">Template Setup Assistant</div>
            <p><strong>Invoked by:</strong> <span class="command">/init-org-template</span></p>
            <p><strong>Purpose:</strong> Guide users through template selection and setup</p>
            <p><strong>Capabilities:</strong></p>
            <ul>
                <li>Analyzes current directory structure</li>
                <li>Loads available templates from plugin's templates/ directory</li>
                <li>Presents template options with recommendations</li>
                <li>Asks clarifying questions about organization size and stage</li>
                <li>Applies selected template with user confirmation</li>
                <li>Guides user to next steps (/set-role)</li>
            </ul>
        </div>
    </div>

    <h1 id="configuration">Configuration Phase</h1>
    <p><strong>When to use:</strong> Setting up or adjusting your role and preferences</p>

    <div class="phase-section phase-configuration">
        <div class="phase-title">Commands</div>

        <div class="command-block">
            <div class="command-name"><span class="command">/show-role-context</span></div>
            <div class="command-description"><strong>Purpose:</strong> Display current role and document loading status</div>
            <p><strong>Shows:</strong></p>
            <ul>
                <li>Configuration hierarchy (both global and project configs)</li>
                <li>Current organizational level</li>
                <li>Current role (with source scope indicator)</li>
                <li>Documents that will load (✓ exists, ! missing, - excluded)</li>
                <li>Custom additions and removals</li>
            </ul>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/update-role-docs [+/-]file ... [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Customize which documents load for your role</div>
            <p><strong>Syntax:</strong></p>
            <ul>
                <li><span class="command">+path/to/doc.md</span> - Add a document</li>
                <li><span class="command">-/quality-standards.md</span> - Remove a document (absolute path with /)</li>
                <li><span class="command">+new.md -old.md +another.md</span> - Multiple changes</li>
            </ul>
            <p><strong>Supports:</strong> Relative paths (relative to current directory), Absolute paths (from repository root, start with /)</p>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/init-role-docs [--reset]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Initialize or reset document references to role guide defaults</div>
            <p><strong>Flags:</strong> <span class="command">--reset</span> - Reset to defaults, clearing customizations</p>
            <p><strong>When to use:</strong> First time setting up a role, want to reset customizations, role guide has been updated</p>
        </div>
    </div>

    <div class="phase-section phase-configuration">
        <div class="phase-title">Agent: Role Guide Generator</div>
        <div class="agent-block">
            <div class="agent-name">Role Guide Generator</div>
            <p><strong>Invoked by:</strong> <span class="command">/create-role-guide [role-name]</span></p>
            <p><strong>Purpose:</strong> Create custom role guides following established patterns</p>
            <p><strong>What it creates:</strong></p>
            <ul>
                <li>Role overview and responsibilities</li>
                <li>Deterministic behaviors (AI MUST follow)</li>
                <li>Agentic opportunities (AI SHOULD suggest)</li>
                <li>Common workflows and example scenarios</li>
                <li>Document references</li>
                <li>Integration with other roles</li>
            </ul>
        </div>
    </div>

    <h1 id="daily">Daily Usage Phase</h1>
    <p><strong>When to use:</strong> Working on projects with established configuration</p>

    <div class="phase-section phase-daily">
        <div class="phase-title">Commands</div>

        <div class="command-block">
            <div class="command-name"><span class="command">/generate-document [type] [--auto]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Generate documents from templates using role context</div>
            <p><strong>Supported Document Types:</strong></p>
            <ul>
                <li><strong>Technical:</strong> ADR, TDD, API docs, operational runbook</li>
                <li><strong>Product:</strong> PRD, feature spec, user story, product overview</li>
                <li><strong>Strategic:</strong> OKRs, roadmap, strategy, vision</li>
                <li><strong>Standards:</strong> Engineering standards, quality standards, security policy</li>
                <li><strong>Process:</strong> Contributing guide, development setup, team handbook</li>
            </ul>
            <p><strong>Flags:</strong> <span class="command">--auto</span> - Batch mode with minimal interaction</p>
        </div>
    </div>

    <div class="phase-section phase-daily">
        <div class="phase-title">Agent: Document Generator</div>
        <div class="agent-block">
            <div class="agent-name">Document Generator</div>
            <p><strong>Invoked by:</strong> <span class="command">/generate-document</span></p>
            <p><strong>Purpose:</strong> Generate high-quality organizational documents from templates</p>
            <p><strong>Capabilities:</strong></p>
            <ul>
                <li>Reads user's role and role guide</li>
                <li>Accesses bundled document templates</li>
                <li>Understands organizational context and level</li>
                <li>Asks document-specific questions</li>
                <li>Generates documents with appropriate structure</li>
                <li>Places documents in correct location</li>
                <li>Updates cross-references</li>
            </ul>
        </div>
    </div>

    <h1 id="maintenance">Maintenance Phase</h1>
    <p><strong>When to use:</strong> Validating setup, syncing updates, troubleshooting</p>

    <div class="phase-section phase-maintenance">
        <div class="phase-title">Commands</div>

        <div class="command-block">
            <div class="command-name"><span class="command">/validate-setup [flags] [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Validate .claude directory structure and configuration</div>
            <p><strong>Flags:</strong></p>
            <ul>
                <li><span class="command">--quick</span> - Essential checks only</li>
                <li><span class="command">--fix</span> - Auto-fix issues with confirmation</li>
                <li><span class="command">--silent</span> - No output unless issues found (for SessionStart hook)</li>
                <li><span class="command">--quiet</span> - One-line summary only (for SessionStart hook)</li>
                <li><span class="command">--summary</span> - Brief checklist of results</li>
            </ul>
            <p><strong>Checks:</strong></p>
            <ul>
                <li>Directory structure exists and is complete</li>
                <li>JSON files are valid</li>
                <li>Role guides exist and are populated</li>
                <li>Reference integrity (roles, documents, templates)</li>
                <li>Cross-references between files</li>
            </ul>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/sync-template [flags] [--global|--project]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Synchronize template updates while preserving customizations</div>
            <p><strong>Flags:</strong></p>
            <ul>
                <li><span class="command">--check-only</span> - Check for updates without applying (for SessionStart hook)</li>
                <li><span class="command">--quiet</span> - Minimal output with check-only</li>
                <li><span class="command">--preview</span> - Show changes without applying</li>
                <li><span class="command">--force</span> - Force update check even if recently checked</li>
            </ul>
            <p><strong>What it does:</strong></p>
            <ul>
                <li>Compares your template version with registry</li>
                <li>Analyzes differences (new files, updates, conflicts)</li>
                <li>Creates automatic backup before changes</li>
                <li>Performs intelligent three-way merge</li>
                <li>Handles conflicts with user input</li>
                <li>Generates detailed migration report</li>
            </ul>
        </div>

        <div class="command-block">
            <div class="command-name"><span class="command">/create-role-guide [role-name]</span></div>
            <div class="command-description"><strong>Purpose:</strong> Create custom role guides following organizational patterns</div>
            <p>Invokes the Role Guide Generator agent to create a comprehensive role guide.</p>
        </div>
    </div>

    <div class="phase-section phase-maintenance">
        <div class="phase-title">Agents: Framework Validator & Template Sync</div>

        <div class="agent-block">
            <div class="agent-name">Framework Validator</div>
            <p><strong>Invoked by:</strong> <span class="command">/validate-setup</span></p>
            <p><strong>Purpose:</strong> Comprehensive validation of .claude directory setup</p>
            <p><strong>Special Modes:</strong></p>
            <ul>
                <li><strong>First-Run Mode:</strong> Detects missing .claude, offers initialization</li>
                <li><strong>Silent Mode (--silent):</strong> No output unless issues found</li>
                <li><strong>Quiet Mode (--quiet):</strong> One-line summary only</li>
                <li><strong>Summary Mode (--summary):</strong> Brief checklist</li>
            </ul>
            <p><strong>Validation Checks:</strong> Critical (directory exists, JSON valid), Important (multiple roles, current role valid), Quality (documents exist, no broken references)</p>
        </div>

        <div class="agent-block">
            <div class="agent-name">Template Sync</div>
            <p><strong>Invoked by:</strong> <span class="command">/sync-template</span></p>
            <p><strong>Purpose:</strong> Intelligent template synchronization with customization preservation</p>
            <p><strong>Capabilities:</strong></p>
            <ul>
                <li>Version detection (compares current vs latest)</li>
                <li>Difference analysis (file-level and content-level diffs)</li>
                <li>Change categorization (safe to auto-apply, merge required, conflict, preserve)</li>
                <li>Backup creation (timestamped backup before changes)</li>
                <li>Intelligent merge (three-way merge, additive merge)</li>
                <li>Conflict resolution (presents options to user)</li>
                <li>Update tracking and validation</li>
            </ul>
        </div>
    </div>

    <h1 id="scope">Understanding Scope: How It Affects Your Reference Files</h1>

    <div class="callout">
        <div class="callout-title">Scope determines where your configuration is stored and which settings take precedence.</div>
    </div>

    <h2>The Three Scopes</h2>

    <table>
        <thead>
            <tr>
                <th>Scope</th>
                <th>Location</th>
                <th>Purpose</th>
                <th>When to Use</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong>Global</strong></td>
                <td>~/.claude/</td>
                <td>Personal defaults that apply across all projects</td>
                <td>You want consistent role and document settings everywhere</td>
            </tr>
            <tr>
                <td><strong>Project</strong></td>
                <td>./.claude/</td>
                <td>Project-specific configuration that overrides global defaults</td>
                <td>Your team has standardized roles and documents for a project</td>
            </tr>
            <tr>
                <td><strong>Auto</strong></td>
                <td>(Dynamic)</td>
                <td>Automatically chooses project or global based on context</td>
                <td>You want smart defaults without thinking about scope</td>
            </tr>
        </tbody>
    </table>

    <h2>Configuration Hierarchy</h2>

    <div class="scope-diagram">┌─────────────────────────────────────────────┐
│  1. Project Config (./.claude/)             │  ← Highest Priority
│     - Project-specific settings             │
│     - Team standards                        │
│     - Overrides global config               │
├─────────────────────────────────────────────┤
│  2. Global Config (~/.claude/)              │  ← Fallback
│     - Your personal defaults                │
│     - Applies when no project override      │
│     - Cross-project consistency             │
├─────────────────────────────────────────────┤
│  3. Plugin Defaults (bundled templates/)    │  ← Last Resort
│     - Built-in templates                    │
│     - Used during initial setup             │
└─────────────────────────────────────────────┘</div>

    <div class="callout">
        <div class="callout-title">Key Concept:</div>
        <p>Project configuration ALWAYS overrides global configuration when both exist. This allows teams to enforce standards while letting individuals maintain personal preferences elsewhere.</p>
    </div>

    <h1 id="reference">Quick Reference</h1>

    <h2>All Slash Commands</h2>

    <table>
        <thead>
            <tr>
                <th>Command</th>
                <th>Purpose</th>
                <th>Key Flags</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><span class="command">/init-org-template</span></td>
                <td>Initialize organizational framework</td>
                <td>--global, --project</td>
            </tr>
            <tr>
                <td><span class="command">/setup-plugin-hooks</span></td>
                <td>Configure SessionStart hook</td>
                <td>--global, --project</td>
            </tr>
            <tr>
                <td><span class="command">/set-role</span></td>
                <td>Set your current role</td>
                <td>--global, --project, --scope</td>
            </tr>
            <tr>
                <td><span class="command">/set-org-level</span></td>
                <td>Set organizational level</td>
                <td>--global, --project</td>
            </tr>
            <tr>
                <td><span class="command">/show-role-context</span></td>
                <td>Display current configuration</td>
                <td>(none)</td>
            </tr>
            <tr>
                <td><span class="command">/update-role-docs</span></td>
                <td>Customize document references</td>
                <td>--global, --project</td>
            </tr>
            <tr>
                <td><span class="command">/init-role-docs</span></td>
                <td>Reset to role guide defaults</td>
                <td>--reset</td>
            </tr>
            <tr>
                <td><span class="command">/generate-document</span></td>
                <td>Generate documents from templates</td>
                <td>--auto</td>
            </tr>
            <tr>
                <td><span class="command">/create-role-guide</span></td>
                <td>Create custom role guide</td>
                <td>(none)</td>
            </tr>
            <tr>
                <td><span class="command">/validate-setup</span></td>
                <td>Validate .claude directory</td>
                <td>--quick, --fix, --silent, --quiet, --summary</td>
            </tr>
            <tr>
                <td><span class="command">/sync-template</span></td>
                <td>Synchronize template updates</td>
                <td>--check-only, --quiet, --preview, --force</td>
            </tr>
        </tbody>
    </table>

    <h2>All Agents</h2>

    <table>
        <thead>
            <tr>
                <th>Agent</th>
                <th>Invoked By</th>
                <th>Purpose</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Template Setup Assistant</td>
                <td>/init-org-template</td>
                <td>Guide template selection and setup</td>
            </tr>
            <tr>
                <td>Role Guide Generator</td>
                <td>/create-role-guide</td>
                <td>Create custom role guides</td>
            </tr>
            <tr>
                <td>Document Generator</td>
                <td>/generate-document</td>
                <td>Generate organizational documents</td>
            </tr>
            <tr>
                <td>Framework Validator</td>
                <td>/validate-setup</td>
                <td>Validate .claude directory setup</td>
            </tr>
            <tr>
                <td>Template Sync</td>
                <td>/sync-template</td>
                <td>Synchronize template updates</td>
            </tr>
        </tbody>
    </table>

    <h2>Key Configuration Files</h2>

    <table>
        <thead>
            <tr>
                <th>File</th>
                <th>Purpose</th>
                <th>Contains</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>preferences.json</td>
                <td>User preferences</td>
                <td>Current role, auto_update_templates, applied_template info</td>
            </tr>
            <tr>
                <td>role-references.json</td>
                <td>Team defaults</td>
                <td>Default document references per role</td>
            </tr>
            <tr>
                <td>role-references.local.json</td>
                <td>Personal customizations</td>
                <td>User-specific document additions/removals (gitignored)</td>
            </tr>
            <tr>
                <td>organizational-level.json</td>
                <td>Org level tracking</td>
                <td>Current organizational level (company/system/product/project)</td>
            </tr>
            <tr>
                <td>settings.json</td>
                <td>Hook configuration</td>
                <td>SessionStart hook commands</td>
            </tr>
        </tbody>
    </table>

    <h1 id="patterns">Common Patterns</h1>

    <h3>Pattern 1: Individual Developer (Global Only)</h3>
    <pre>/init-org-template --global
/set-role software-engineer --global
# Works everywhere automatically</pre>

    <h3>Pattern 2: Team Project (Project Only)</h3>
    <pre>cd team-project
/init-org-template --project
/set-role qa-engineer --project
git add .claude/
git commit -m "Add team configuration"</pre>

    <h3>Pattern 3: Hybrid (Recommended)</h3>
    <pre># Global defaults for personal work
/set-role software-engineer --global

# Override for specific projects
cd special-project
/set-role devops-engineer --project</pre>

    <h1 id="hooks">SessionStart Hook</h1>

    <p><strong>Purpose:</strong> Automatic validation and update checks when starting a new session</p>

    <div class="callout">
        <div class="callout-title">Default Configuration (.claude/settings.json):</div>
        <pre>{{
  "hooks": {{
    "SessionStart": [
      "/validate-setup --quiet",
      "/sync-template --check-only"
    ]
  }}
}}</pre>
    </div>

    <p><strong>What Happens:</strong></p>
    <ul>
        <li><span class="command">/validate-setup --quiet</span> - Validates setup, shows one-line summary</li>
        <li><span class="command">/sync-template --check-only</span> - Checks for updates (respects auto_update_templates preference)</li>
    </ul>

    <p><strong>Example Outputs:</strong></p>
    <pre>✓ Setup valid
✓ Template up-to-date (software-org v1.0.0)</pre>

    <p>Or:</p>
    <pre>⚠ Setup incomplete - run /init-org-template to initialize
ℹ Template update available (v1.0.0 → v1.1.0). Run /sync-template to update.</pre>

    <div style="margin-top: 50px; padding-top: 20px; border-top: 2px solid #E2E8F0; text-align: center; color: #4A5568; font-size: 9pt;">
        <p>For more information, visit the plugin repository or check the documentation in your .claude/docs/ directory.</p>
        <p>Generated with Claude Code • Role Context Manager Plugin v1.3.0</p>
    </div>
</body>
</html>
    """

    return html

def generate_markdown():
    """Generate the complete markdown content for the cheatsheet."""
    md = """# Role Context Manager - Cheatsheet

**Plugin Version:** 1.3.0
**Description:** Role-based document context manager for Claude Code

---

## Table of Contents

- [Initial Setup Phase](#initial-setup-phase)
- [Configuration Phase](#configuration-phase)
- [Daily Usage Phase](#daily-usage-phase)
- [Maintenance Phase](#maintenance-phase)
- [Understanding Scope](#understanding-scope)
- [Quick Reference](#quick-reference)
- [Common Patterns](#common-patterns)
- [SessionStart Hook](#sessionstart-hook)

---

## Initial Setup Phase

**When to use:** First-time user or new project initialization

### Commands

#### `/init-org-template [--global|--project]`

**Purpose:** Initialize organizational framework from a template

**What it does:**
- Invokes Template Setup Assistant agent
- Analyzes your project structure
- Presents available templates (software-org, startup-org)
- Applies chosen template to appropriate scope
- Records template tracking for auto-updates

**Flags:** `--global` (apply to ~/.claude/), `--project` (apply to ./.claude/)

---

#### `/setup-plugin-hooks [--global|--project]`

**Purpose:** Configure SessionStart hook for automatic validation

**What it configures:**
- Adds SessionStart hook to settings.json
- Sets up automatic validation and update checks
- Creates setup marker file

---

#### `/set-role [role-name] [--global|--project]`

**Purpose:** Set your current role to determine which documents load

**Parameters:** role-name (required, e.g., software-engineer, product-manager)

**What it does:**
- Validates role exists at current organizational level
- Updates preferences.json with your role
- Initializes role-specific document references
- Displays documents that will load on next session

---

#### `/set-org-level [level] [--global|--project]`

**Purpose:** Explicitly set organizational level

**Levels:**
- **company** - Root level (CTO, CPO, CISO, VP Engineering)
- **system** - Coordination level (Engineering Manager, Platform Engineer)
- **product** - Product management level (Product Manager, QA Manager, UX Designer)
- **project** - Implementation level (Software Engineer, DevOps Engineer, QA Engineer)

**When to use:** Directory structure doesn't match standard patterns, want to override automatic detection

---

### Agent: Template Setup Assistant

**Invoked by:** `/init-org-template`

**Purpose:** Guide users through template selection and setup

**Capabilities:**
- Analyzes current directory structure
- Loads available templates from plugin's templates/ directory
- Presents template options with recommendations
- Asks clarifying questions about organization size and stage
- Applies selected template with user confirmation
- Guides user to next steps (/set-role)

---

## Configuration Phase

**When to use:** Setting up or adjusting your role and preferences

### Commands

#### `/show-role-context`

**Purpose:** Display current role and document loading status

**Shows:**
- Configuration hierarchy (both global and project configs)
- Current organizational level
- Current role (with source scope indicator)
- Documents that will load (✓ exists, ! missing, - excluded)
- Custom additions and removals

---

#### `/update-role-docs [+/-]file ... [--global|--project]`

**Purpose:** Customize which documents load for your role

**Syntax:**
- `+path/to/doc.md` - Add a document
- `-/quality-standards.md` - Remove a document (absolute path with /)
- `+new.md -old.md +another.md` - Multiple changes

**Supports:** Relative paths (relative to current directory), Absolute paths (from repository root, start with /)

---

#### `/init-role-docs [--reset]`

**Purpose:** Initialize or reset document references to role guide defaults

**Flags:** `--reset` - Reset to defaults, clearing customizations

**When to use:** First time setting up a role, want to reset customizations, role guide has been updated

---

### Agent: Role Guide Generator

**Invoked by:** `/create-role-guide [role-name]`

**Purpose:** Create custom role guides following established patterns

**What it creates:**
- Role overview and responsibilities
- Deterministic behaviors (AI MUST follow)
- Agentic opportunities (AI SHOULD suggest)
- Common workflows and example scenarios
- Document references
- Integration with other roles

---

## Daily Usage Phase

**When to use:** Working on projects with established configuration

### Commands

#### `/generate-document [type] [--auto]`

**Purpose:** Generate documents from templates using role context

**Supported Document Types:**
- **Technical:** ADR, TDD, API docs, operational runbook
- **Product:** PRD, feature spec, user story, product overview
- **Strategic:** OKRs, roadmap, strategy, vision
- **Standards:** Engineering standards, quality standards, security policy
- **Process:** Contributing guide, development setup, team handbook

**Flags:** `--auto` - Batch mode with minimal interaction

---

### Agent: Document Generator

**Invoked by:** `/generate-document`

**Purpose:** Generate high-quality organizational documents from templates

**Capabilities:**
- Reads user's role and role guide
- Accesses bundled document templates
- Understands organizational context and level
- Asks document-specific questions
- Generates documents with appropriate structure
- Places documents in correct location
- Updates cross-references

---

## Maintenance Phase

**When to use:** Validating setup, syncing updates, troubleshooting

### Commands

#### `/validate-setup [flags] [--global|--project]`

**Purpose:** Validate .claude directory structure and configuration

**Flags:**
- `--quick` - Essential checks only
- `--fix` - Auto-fix issues with confirmation
- `--silent` - No output unless issues found (for SessionStart hook)
- `--quiet` - One-line summary only (for SessionStart hook)
- `--summary` - Brief checklist of results

**Checks:**
- Directory structure exists and is complete
- JSON files are valid
- Role guides exist and are populated
- Reference integrity (roles, documents, templates)
- Cross-references between files

---

#### `/sync-template [flags] [--global|--project]`

**Purpose:** Synchronize template updates while preserving customizations

**Flags:**
- `--check-only` - Check for updates without applying (for SessionStart hook)
- `--quiet` - Minimal output with check-only
- `--preview` - Show changes without applying
- `--force` - Force update check even if recently checked

**What it does:**
- Compares your template version with registry
- Analyzes differences (new files, updates, conflicts)
- Creates automatic backup before changes
- Performs intelligent three-way merge
- Handles conflicts with user input
- Generates detailed migration report

---

#### `/create-role-guide [role-name]`

**Purpose:** Create custom role guides following organizational patterns

Invokes the Role Guide Generator agent to create a comprehensive role guide.

---

### Agents: Framework Validator & Template Sync

#### Framework Validator

**Invoked by:** `/validate-setup`

**Purpose:** Comprehensive validation of .claude directory setup

**Special Modes:**
- **First-Run Mode:** Detects missing .claude, offers initialization
- **Silent Mode (--silent):** No output unless issues found
- **Quiet Mode (--quiet):** One-line summary only
- **Summary Mode (--summary):** Brief checklist

**Validation Checks:** Critical (directory exists, JSON valid), Important (multiple roles, current role valid), Quality (documents exist, no broken references)

---

#### Template Sync

**Invoked by:** `/sync-template`

**Purpose:** Intelligent template synchronization with customization preservation

**Capabilities:**
- Version detection (compares current vs latest)
- Difference analysis (file-level and content-level diffs)
- Change categorization (safe to auto-apply, merge required, conflict, preserve)
- Backup creation (timestamped backup before changes)
- Intelligent merge (three-way merge, additive merge)
- Conflict resolution (presents options to user)
- Update tracking and validation

---

## Understanding Scope

### How Scope Affects Your Reference Files

> **Important:** Scope determines where your configuration is stored and which settings take precedence.

### The Three Scopes

| Scope | Location | Purpose | When to Use |
|-------|----------|---------|-------------|
| **Global** | `~/.claude/` | Personal defaults that apply across all projects | You want consistent role and document settings everywhere |
| **Project** | `./.claude/` | Project-specific configuration that overrides global defaults | Your team has standardized roles and documents for a project |
| **Auto** | (Dynamic) | Automatically chooses project or global based on context | You want smart defaults without thinking about scope |

### Configuration Hierarchy

```
┌─────────────────────────────────────────────┐
│  1. Project Config (./.claude/)             │  ← Highest Priority
│     - Project-specific settings             │
│     - Team standards                        │
│     - Overrides global config               │
├─────────────────────────────────────────────┤
│  2. Global Config (~/.claude/)              │  ← Fallback
│     - Your personal defaults                │
│     - Applies when no project override      │
│     - Cross-project consistency             │
├─────────────────────────────────────────────┤
│  3. Plugin Defaults (bundled templates/)    │  ← Last Resort
│     - Built-in templates                    │
│     - Used during initial setup             │
└─────────────────────────────────────────────┘
```

> **Key Concept:** Project configuration ALWAYS overrides global configuration when both exist. This allows teams to enforce standards while letting individuals maintain personal preferences elsewhere.

---

## Quick Reference

### All Slash Commands

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `/init-org-template` | Initialize organizational framework | `--global`, `--project` |
| `/setup-plugin-hooks` | Configure SessionStart hook | `--global`, `--project` |
| `/set-role` | Set your current role | `--global`, `--project`, `--scope` |
| `/set-org-level` | Set organizational level | `--global`, `--project` |
| `/show-role-context` | Display current configuration | (none) |
| `/update-role-docs` | Customize document references | `--global`, `--project` |
| `/init-role-docs` | Reset to role guide defaults | `--reset` |
| `/generate-document` | Generate documents from templates | `--auto` |
| `/create-role-guide` | Create custom role guide | (none) |
| `/validate-setup` | Validate .claude directory | `--quick`, `--fix`, `--silent`, `--quiet`, `--summary` |
| `/sync-template` | Synchronize template updates | `--check-only`, `--quiet`, `--preview`, `--force` |

### All Agents

| Agent | Invoked By | Purpose |
|-------|-----------|---------|
| Template Setup Assistant | `/init-org-template` | Guide template selection and setup |
| Role Guide Generator | `/create-role-guide` | Create custom role guides |
| Document Generator | `/generate-document` | Generate organizational documents |
| Framework Validator | `/validate-setup` | Validate .claude directory setup |
| Template Sync | `/sync-template` | Synchronize template updates |

### Key Configuration Files

| File | Purpose | Contains |
|------|---------|----------|
| `preferences.json` | User preferences | Current role, auto_update_templates, applied_template info |
| `role-references.json` | Team defaults | Default document references per role |
| `role-references.local.json` | Personal customizations | User-specific document additions/removals (gitignored) |
| `organizational-level.json` | Org level tracking | Current organizational level (company/system/product/project) |
| `settings.json` | Hook configuration | SessionStart hook commands |

---

## Common Patterns

### Pattern 1: Individual Developer (Global Only)

```bash
/init-org-template --global
/set-role software-engineer --global
# Works everywhere automatically
```

### Pattern 2: Team Project (Project Only)

```bash
cd team-project
/init-org-template --project
/set-role qa-engineer --project
git add .claude/
git commit -m "Add team configuration"
```

### Pattern 3: Hybrid (Recommended)

```bash
# Global defaults for personal work
/set-role software-engineer --global

# Override for specific projects
cd special-project
/set-role devops-engineer --project
```

---

## SessionStart Hook

**Purpose:** Automatic validation and update checks when starting a new session

### Default Configuration

`.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --quiet",
      "/sync-template --check-only"
    ]
  }
}
```

### What Happens

- `/validate-setup --quiet` - Validates setup, shows one-line summary
- `/sync-template --check-only` - Checks for updates (respects auto_update_templates preference)

### Example Outputs

Success:
```
✓ Setup valid
✓ Template up-to-date (software-org v1.0.0)
```

Issues detected:
```
⚠ Setup incomplete - run /init-org-template to initialize
ℹ Template update available (v1.0.0 → v1.1.0). Run /sync-template to update.
```

---

**For more information:** Visit the plugin repository or check the documentation in your .claude/docs/ directory.

**Generated with:** Claude Code • Role Context Manager Plugin v1.3.0
"""

    return md

def main():
    """Main function to generate both PDF and Markdown cheatsheets."""
    print("Generating Role Context Manager Cheatsheet...")

    # Get the plugin root directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    plugin_root = os.path.dirname(script_dir)
    pdf_path = os.path.join(plugin_root, 'CHEATSHEET.pdf')
    md_path = os.path.join(plugin_root, 'CHEATSHEET.md')

    # Generate PDF
    print("\n[1/2] Creating HTML content...")
    html_content = generate_html()

    print(f"Converting to PDF at {pdf_path}...")
    HTML(string=html_content).write_pdf(pdf_path)

    # Get PDF file size
    pdf_size = os.path.getsize(pdf_path)
    pdf_size_mb = pdf_size / (1024 * 1024)

    print(f"✓ PDF generated!")
    print(f"  Location: {pdf_path}")
    print(f"  File size: {pdf_size_mb:.2f} MB")

    # Generate Markdown
    print(f"\n[2/2] Creating Markdown content...")
    md_content = generate_markdown()

    with open(md_path, 'w', encoding='utf-8') as f:
        f.write(md_content)

    # Get Markdown file size
    md_size = os.path.getsize(md_path)
    md_size_kb = md_size / 1024

    print(f"✓ Markdown generated!")
    print(f"  Location: {md_path}")
    print(f"  File size: {md_size_kb:.2f} KB")

    print(f"\n✓ Both cheatsheets generated successfully!")

    return pdf_path, md_path

if __name__ == '__main__':
    main()
