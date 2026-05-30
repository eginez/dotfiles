#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"

fail() {
  echo "[FAIL] $*"
  exit 1
}

pass() {
  echo "[PASS] $*"
}

[[ -f "$REPO_ROOT/.gitattributes" ]] || fail ".gitattributes should exist"
pass ".gitattributes exists"

grep -F -q -- '*.sh text eol=lf' "$REPO_ROOT/.gitattributes" || fail ".gitattributes should enforce LF for .sh files"
pass ".gitattributes enforces LF for .sh files"
