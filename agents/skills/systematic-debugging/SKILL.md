---
name: systematic-debugging
description: Diagnose bugs with a root-cause-first workflow before attempting fixes. Use when a bug report, test failure, unexpected behavior, or regression appears.
metadata:
  source: obra/superpowers
  adapted-for: cross-tool-local-agents
---

# Systematic Debugging

Use this skill before changing code to fix a bug.

## Core rule

Do not propose or implement a fix until the failure is reproduced and the likely root cause is identified.

## Workflow

1. Restate the failure in one sentence.
2. Reproduce it with the smallest available command, test, or input.
3. Record the exact observed behavior.
4. Narrow the scope:
   - where does the bad output first appear?
   - what recent assumption is most likely wrong?
   - what code paths are definitely not involved?
5. Form 1-3 hypotheses.
6. Check the cheapest hypothesis first with direct evidence.
7. Once the cause is identified, add or update a regression test.
8. Implement the smallest fix that makes the new test pass.
9. Re-run the focused test, then the broader relevant verification.

## Guardrails

- Do not patch symptoms without evidence.
- Do not stack multiple speculative fixes.
- Do not widen scope unless the evidence forces it.
- Prefer existing logs, focused tests, and direct code inspection over broad guesswork.

## Expected output

Return:
- failure summary
- reproduction command
- root cause
- minimal fix
- verification run
