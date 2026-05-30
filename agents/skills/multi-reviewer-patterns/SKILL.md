---
name: multi-reviewer-patterns
description: Coordinate multiple independent reviewers with different focus areas and consolidate their findings. Use for meaningful changes where one reviewer is not enough.
metadata:
  source: wshobson/agents
  adapted-for: cross-tool-local-agents
---

# Multi-Reviewer Patterns

Use this skill when review quality improves by splitting concerns across multiple agents.

## Recommended reviewer split

For v1, use two reviewers:
- architecture and design reviewer
- implementation and test reviewer

Add more reviewers only when the change clearly needs it.

## Workflow

1. Prepare a shared review packet:
   - goal
   - constraints
   - changed files or diff
   - tests run
2. Dispatch reviewers independently.
3. Ask each reviewer to report findings with severity and file references.
4. Consolidate results:
   - merge duplicates
   - keep the clearest wording
   - preserve the highest reasonable severity
5. Fix valid findings.
6. Re-run verification.
7. Report remaining risks.

## Guardrails

- Do not let one reviewer anchor the others.
- Do not average away serious findings.
- Prefer correctness and regression risk over style nitpicks.

## Expected output

Return:
- reviewer roles used
- consolidated findings
- duplicates removed
- remaining risk after fixes
