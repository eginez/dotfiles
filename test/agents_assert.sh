#!/bin/bash
# agents_assert.sh — verifies install-agents.sh behavior using temp dirs.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
TMP_ROOT="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

PASS=0
FAIL=1
_failures=0

pass() { echo "[PASS] $*"; }
fail() { echo "[FAIL] $*"; ((_failures++)) || true; }

assert_output_contains() {
  local description=$1 output=$2 pattern=$3
  if printf '%s\n' "$output" | grep -q -- "$pattern"; then
    pass "$description"
  else
    fail "$description (expected pattern '$pattern')"
  fi
}

assert_symlink_target() {
  local description=$1 path=$2 pattern=$3
  if [[ ! -L "$path" ]]; then
    fail "$description: $path is not a symlink"
    return
  fi

  local target
  target=$(readlink "$path")
  if printf '%s\n' "$target" | grep -q -- "$pattern"; then
    pass "$description: $path -> $target"
  else
    fail "$description: $path -> '$target' (expected '$pattern')"
  fi
}

CLAUDE_DIR="$TMP_ROOT/claude-skills"
OPENCODE_DIR="$TMP_ROOT/opencode-skills"

echo ""
echo "── install-agents contract ───────────────────────────────────────────────"

set +e
missing_target_output=$(bash "$REPO_ROOT/install-agents.sh" 2>&1)
missing_target_status=$?
set -e

if [[ $missing_target_status -ne 0 ]]; then
  pass "missing --target exits non-zero"
else
  fail "missing --target should exit non-zero"
fi
assert_output_contains "missing --target prints usage" "$missing_target_output" "--target"

dry_run_output=$(CLAUDE_SKILLS_DIR="$CLAUDE_DIR" OPENCODE_SKILLS_DIR="$OPENCODE_DIR" \
  bash "$REPO_ROOT/install-agents.sh" --target all --dry-run 2>&1)
assert_output_contains "dry-run mentions claude target" "$dry_run_output" "$CLAUDE_DIR"
assert_output_contains "dry-run mentions opencode target" "$dry_run_output" "$OPENCODE_DIR"

CLAUDE_SKILLS_DIR="$CLAUDE_DIR" OPENCODE_SKILLS_DIR="$OPENCODE_DIR" \
  bash "$REPO_ROOT/install-agents.sh" --target all

for skill in \
  systematic-debugging \
  requesting-code-review \
  subagent-driven-development \
  context-driven-development \
  multi-reviewer-patterns
do
  assert_symlink_target \
    "claude installs $skill" \
    "$CLAUDE_DIR/$skill" \
    "agents/skills/$skill$"
  assert_symlink_target \
    "opencode installs $skill" \
    "$OPENCODE_DIR/$skill" \
    "agents/skills/$skill$"
done

echo ""
echo "──────────────────────────────────────────────────────────────────────────"
if [[ $_failures -eq 0 ]]; then
  echo "All agent installer assertions passed."
  exit 0
else
  echo "$_failures agent installer assertion(s) failed."
  exit 1
fi
