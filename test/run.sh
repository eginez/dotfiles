#!/bin/bash
# test/run.sh — builds the Docker image and runs both test passes.
#
# Usage:
#   ./test/run.sh              # run all passes
#   ./test/run.sh --no-build   # skip docker build (use cached image)

set -euo pipefail

IMAGE="dotfiles-test"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NO_BUILD=false

for arg in "$@"; do
  case "$arg" in
    --no-build) NO_BUILD=true ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

# ─── Colours ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

header() { echo -e "\n${BOLD}${CYAN}══ $* ══${RESET}"; }
ok()     { echo -e "${GREEN}✓ $*${RESET}"; }
err()    { echo -e "${RED}✗ $*${RESET}"; }

# ─── Build ────────────────────────────────────────────────────────────────────

if $NO_BUILD; then
  header "Skipping Docker build (--no-build)"
else
  header "Building Docker image"
  docker build \
    -f "$REPO_ROOT/test/Dockerfile" \
    -t "$IMAGE" \
    "$REPO_ROOT"
  ok "Image built: $IMAGE"
fi

# ─── Pass 1: Full install (real downloads) ────────────────────────────────────

header "Pass 1 — Full install (including downloads)"

if docker run --rm \
  --name dotfiles-test-full \
  "$IMAGE" \
  bash -c "cd /home/testuser/dotfiles && bash install.sh && bash test/assert.sh"
then
  ok "Pass 1 PASSED"
  PASS1=true
else
  err "Pass 1 FAILED"
  PASS1=false
fi

# ─── Pass 2: Dry-run (must leave no files behind) ────────────────────────────

header "Pass 2 — Dry-run (no side effects)"

DRY_RUN_CHECK='
  set -e
  cd /home/testuser/dotfiles
  bash install.sh --dry-run

  # None of these should exist after a dry-run
  failures=0
  for path in ~/.zshrc ~/.tmux.conf ~/.gitconfig ~/.config/nvim; do
    if [[ -e "$path" ]]; then
      echo "[FAIL] dry-run: $path was created but should not have been"
      (( failures++ )) || true
    else
      echo "[PASS] dry-run: $path was not created (correct)"
    fi
  done

  if [[ $failures -eq 0 ]]; then
    echo "Dry-run pass: no side effects detected."
    exit 0
  else
    echo "$failures dry-run failure(s)."
    exit 1
  fi
'

if docker run --rm \
  --name dotfiles-test-dryrun \
  "$IMAGE" \
  bash -c "$DRY_RUN_CHECK"
then
  ok "Pass 2 PASSED"
  PASS2=true
else
  err "Pass 2 FAILED"
  PASS2=false
fi

# ─── Summary ──────────────────────────────────────────────────────────────────

header "Summary"

$PASS1 && ok "Pass 1 (full install):  PASSED" || err "Pass 1 (full install):  FAILED"
$PASS2 && ok "Pass 2 (dry-run):       PASSED" || err "Pass 2 (dry-run):       FAILED"

if $PASS1 && $PASS2; then
  echo ""
  ok "All tests passed."
  exit 0
else
  echo ""
  err "Some tests failed."
  exit 1
fi
