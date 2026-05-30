#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_ROOT="$SCRIPT_DIR/agents/skills"

DRY_RUN=false
TARGET=""

CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"

log() {
  echo "==> $*"
}

log_sub() {
  echo "    $*"
}

run_cmd() {
  if $DRY_RUN; then
    echo "    [dry-run] would run: $*"
  else
    "$@"
  fi
}

usage() {
  echo "Usage: $0 --target <claude|opencode|all> [--dry-run]"
  echo ""
  echo "Installs all tracked agent skills from agents/skills into global harness directories."
  exit 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --target)
        [[ $# -ge 2 ]] || usage
        TARGET="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --help|-h)
        usage
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage
        ;;
    esac
  done

  if [[ -z "$TARGET" ]]; then
    echo "--target is required" >&2
    usage
  fi

  case "$TARGET" in
    claude|opencode|all) ;;
    *)
      echo "Invalid target: $TARGET" >&2
      usage
      ;;
  esac
}

discover_skills() {
  if [[ ! -d "$SKILLS_ROOT" ]]; then
    echo "Skills root not found: $SKILLS_ROOT" >&2
    exit 1
  fi

  local matches=()
  local skill_file
  shopt -s nullglob
  for skill_file in "$SKILLS_ROOT"/*/SKILL.md; do
    matches+=("$(dirname "$skill_file")")
  done
  shopt -u nullglob

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No skills found under $SKILLS_ROOT" >&2
    exit 1
  fi

  SKILL_DIRS=("${matches[@]}")
}

ensure_target_dir() {
  local dir=$1
  log_sub "Ensuring $dir exists"
  run_cmd mkdir -p "$dir"
}

link_skill_dir() {
  local src=$1 dst_root=$2
  local name dst

  name="$(basename "$src")"
  dst="$dst_root/$name"

  if [[ -L "$dst" ]]; then
    log_sub "Replacing symlink $dst"
    run_cmd rm "$dst"
  elif [[ -e "$dst" ]]; then
    echo "Refusing to overwrite non-symlink path: $dst" >&2
    exit 1
  fi

  log_sub "Linking $src -> $dst"
  run_cmd ln -s "$src" "$dst"
}

install_to_target() {
  local label=$1 dst_root=$2
  log "Installing agent skills for $label..."
  ensure_target_dir "$dst_root"

  local skill_dir
  for skill_dir in "${SKILL_DIRS[@]}"; do
    link_skill_dir "$skill_dir" "$dst_root"
  done
}

main() {
  parse_args "$@"
  discover_skills

  case "$TARGET" in
    claude)
      install_to_target "claude" "$CLAUDE_SKILLS_DIR"
      ;;
    opencode)
      install_to_target "opencode" "$OPENCODE_SKILLS_DIR"
      ;;
    all)
      install_to_target "claude" "$CLAUDE_SKILLS_DIR"
      install_to_target "opencode" "$OPENCODE_SKILLS_DIR"
      ;;
  esac

  log "Agent skills install done."
}

main "$@"
