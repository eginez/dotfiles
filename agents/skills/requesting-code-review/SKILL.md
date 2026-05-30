---
name: requesting-code-review
description: Request independent review from separate agents before declaring implementation complete. Use when a meaningful change has been made or a task is nearing completion.
metadata:
  source: obra/superpowers
  adapted-for: cross-tool-local-agents
---

# Requesting Code Review

Use this skill after implementation work and before claiming completion.

## Core rule

Review must be performed by agents other than the one that wrote the code.

## Workflow

1. Gather review inputs:
   - goal
   - constraints
   - changed files
   - relevant tests run
   - known risks
2. Dispatch at least one independent reviewer.
3. For non-trivial work, prefer multiple reviewers with distinct focus areas.
4. Ask reviewers to prioritize:
   - bugs
   - regressions
   - missing tests
   - risky assumptions
   - maintainability concerns that affect correctness
5. Integrate valid findings.
6. Re-run verification after changes.
7. Summarize findings, fixes, and any remaining risk.

## Reviewer packet

Reviewers should receive:
- the task goal
- relevant constraints
- the diff or changed files
- test evidence

Reviewers should not rely on the builder's internal reasoning unless independence is intentionally being relaxed.

## Expected output

Return:
- which reviewers were used
- findings by severity
- fixes made in response
- remaining risks or test gaps
