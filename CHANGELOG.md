# Changelog

All notable changes to workflow-kit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added
- Initial release of workflow-kit
- 6 core agents: master-orchestrator, issue-executor, issue-creator, issue-closer, agent-installer, workflow-orchestrator
- 11 commands: workflow (issue, commit, create-issue, discover, init, update, status), agents (install, search, list, remove)
- 2 skills: workflow-rules, issue-template
- Template variables for project-specific GitHub configuration
- Copy-based installation with version tracking
- Override preservation during updates

### Changed
- Extracted from tuti-cli into standalone repository
- Added {{GITHUB_OWNER}}/{{GITHUB_REPO}} template variables

### Removed
- Project-specific hardcoded values
