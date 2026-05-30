#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
SCRIPT="$REPO_ROOT/install-agents.ps1"

fail() {
  echo "[FAIL] $*"
  exit 1
}

pass() {
  echo "[PASS] $*"
}

[[ -f "$SCRIPT" ]] || fail "install-agents.ps1 should exist"
pass "install-agents.ps1 exists"

grep -F -q -- "claude|opencode|all" "$SCRIPT" || fail "script should validate claude|opencode|all targets"
pass "target validation present"

grep -F -q -- "Join-Path \$env:USERPROFILE '.claude\skills'" "$SCRIPT" || fail "script should install to ~/.claude/skills equivalent on Windows"
pass "claude path present"

grep -F -q -- "Join-Path \$env:APPDATA 'opencode\skills'" "$SCRIPT" || fail "script should install to opencode roaming config path"
pass "opencode path present"

grep -F -q -- 'ItemType Junction' "$SCRIPT" || fail "script should create junctions for skill directories"
pass "junction install behavior present"

grep -F -q -- '[switch]$DryRun' "$SCRIPT" || fail "script should support -DryRun"
pass "dry-run support present"

grep -F -q -- "ValidateSet('claude', 'opencode', 'all')" "$SCRIPT" || fail "script should validate allowed targets"
pass "powershell target validation present"
