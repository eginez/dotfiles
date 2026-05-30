# Agent Skills

This directory contains the tracked source of truth for the local agent skill pack.

## Included skills

- `systematic-debugging`
- `requesting-code-review`
- `subagent-driven-development`
- `context-driven-development`
- `multi-reviewer-patterns`

## Install

Install into Claude Code global skills:

```bash
./install-agents.sh --target claude
```

Install into OpenCode global skills:

```bash
./install-agents.sh --target opencode
```

Install into both:

```bash
./install-agents.sh --target all
```

On Windows PowerShell:

```powershell
.\install-agents.ps1 -Target all
```

Preview actions without changing anything:

```bash
./install-agents.sh --target all --dry-run
```

## Notes

- The installer always installs all tracked skills.
- Installation uses symlinks back to `agents/skills/`.
- On Windows, directory installs use junctions.
- v1 installs only to global harness paths.
- Future work may add a local project mode.
