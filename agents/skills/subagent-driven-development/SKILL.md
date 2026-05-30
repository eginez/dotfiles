---
name: subagent-driven-development
description: Execute work through a lead agent that plans, dispatches specialist agents, and integrates reviewed results. Use for multi-step implementation where isolated specialist work improves focus.
metadata:
  source: obra/superpowers
  adapted-for: cross-tool-local-agents
---

# Subagent-Driven Development

Use this skill when the work is large enough to benefit from focused background agents.

## Operating model

- One lead agent owns the task.
- The lead agent may triage and draft the spec or plan.
- Specialist agents handle focused implementation or investigation work.
- Review is performed by separate agents, not by the builder agent alone.

## Lead agent responsibilities

1. Clarify the goal and constraints.
2. Create the task packet:
   - objective
   - constraints
   - success criteria
   - relevant files
   - open risks
3. Decompose work into focused sub-tasks.
4. Dispatch specialist agents with only the context they need.
5. Integrate results.
6. Dispatch independent review agents.
7. Apply fixes from valid findings.
8. Run final verification.

## Specialist agent packet

Each specialist should receive:
- the exact sub-task
- the relevant portion of the spec or plan
- target files
- constraints
- expected return format

Do not send the full conversation by default.

## Expected return format

Each specialist should return:
- what was checked
- what changed or was found
- unresolved risks
- recommended next step

## Review rule

For meaningful changes, use separate review agents before completion.
