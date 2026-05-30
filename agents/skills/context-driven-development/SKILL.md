---
name: context-driven-development
description: Manage agent context through durable artifacts and task packets instead of shared chat history. Use when coordinating multiple agents or preserving stable project guidance.
metadata:
  source: wshobson/agents
  adapted-for: cross-tool-local-agents
---

# Context-Driven Development

Use this skill when multiple agents need consistent context without inheriting the same conversation history.

## Core rule

Shared truth lives in durable artifacts, not in implicit chat memory.

## Context layers

### Durable context

Stable project guidance such as:
- repo instructions
- architecture notes
- constraints
- recurring mistakes to avoid

### Task packet

The lead agent should assemble a packet containing:
- goal
- constraints
- success criteria
- spec or plan section
- relevant files
- open questions
- open risks

### Specialist context

Each background agent gets only the slice it needs.

### Reviewer context

Reviewers should get:
- goal
- constraints
- changed files or diff
- verification evidence

Keep reviewer context independent from the builder's reasoning unless there is a deliberate reason to share it.

## Promotion rule

Only stable lessons should be promoted into durable context. Do not store raw chat transcripts as memory.

## Expected output

Return:
- durable context used
- task packet contents
- what was intentionally excluded from specialist or reviewer context
