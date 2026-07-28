# Copilot MCP + Skills for tei2html

This directory contains the repository Model & Capabilities Profile (MCP) and skill stubs
used to help the assistant operate safely and effectively on this repo.

Files added:
- .copilot/mcp.yaml — main profile (model, permissions, skills)
- .copilot/skills/perl-tools.skill.yaml — Perl scripts in tools/
- .copilot/skills/pptools.skill.yaml — Perl utilities in pptools/
- .copilot/skills/xspec.skill.yaml — XSpec tests in xspec/

What the skills do:
- Provide commands and safe run configurations for running scripts, linters, and tests.
- Encourage exact-file references and recommending focused diffs for code fixes.
- Gate any write/PR operations behind explicit user confirmation.

Before committing:
- Confirm the default model (currently gpt-4o-mini).
- Confirm the test-runner defaults you prefer for xspec and Perl tests. Suggested:
  - XSpec: "xspec" (if repository uses xspec gem) or "mvn test" if there is a pom.xml.
  - Perl tests: "prove -l" or "prove -lv".
- If you want additional skills (linting, CI-actions management, docs automation), tell me and I’ll add them.

Next step:
- Reply "Commit" to create these files on branch copilot/mcp-setup, or request edits.
