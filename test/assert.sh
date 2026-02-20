#!/bin/bash
# assert.sh — verifies dotfiles are installed correctly.
# Usable standalone on a real machine or inside the Docker test container.
# Exit code: 0 if all pass, 1 if any fail.

PASS=0
FAIL=1
_failures=0

pass() { echo "[PASS] $*"; }
fail() { echo "[FAIL] $*"; (( _failures++ )) || true; }

assert_symlink() {
  local description=$1 path=$2
  if [[ -L "$path" ]]; then
    pass "$description: $path is a symlink"
  else
    fail "$description: $path is not a symlink (got: $(ls -la "$path" 2>&1))"
  fi
}

assert_symlink_target() {
  local description=$1 path=$2 pattern=$3
  local target
  target=$(readlink "$path" 2>/dev/null || echo "")
  if echo "$target" | grep -q "$pattern"; then
    pass "$description: $path -> $target"
  else
    fail "$description: $path -> '$target' (expected to match '$pattern')"
  fi
}

assert_not_exists() {
  local description=$1 path=$2
  if [[ ! -e "$path" ]]; then
    pass "$description: $path does not exist (correct)"
  else
    fail "$description: $path should not exist but does"
  fi
}

assert_cmd_exists() {
  local description=$1 cmd=$2
  if command -v "$cmd" &>/dev/null; then
    pass "$description: '$cmd' found at $(command -v "$cmd")"
  else
    fail "$description: '$cmd' not found in PATH"
  fi
}

assert_file_exists() {
  local description=$1 path=$2
  if [[ -f "$path" || -x "$path" ]]; then
    pass "$description: $path exists"
  else
    fail "$description: $path does not exist"
  fi
}

assert_cmd_output() {
  local description=$1 pattern=$2
  shift 2
  local output
  output=$("$@" 2>&1) || true
  if echo "$output" | grep -q "$pattern"; then
    pass "$description"
  else
    fail "$description (output: '$output', expected pattern: '$pattern')"
  fi
}

assert_cmd_no_output() {
  local description=$1 pattern=$2
  shift 2
  local output
  output=$("$@" 2>&1) || true
  if echo "$output" | grep -q "$pattern"; then
    fail "$description (output contained forbidden pattern: '$pattern')"
  else
    pass "$description"
  fi
}

# ─── Symlink assertions ───────────────────────────────────────────────────────

echo ""
echo "── Symlinks ──────────────────────────────────────────────────────────────"

assert_symlink        "zshrc symlink"       "$HOME/.zshrc"
assert_symlink_target "zshrc target"        "$HOME/.zshrc"       "zsh/zshrc"

assert_symlink        "p10k symlink"        "$HOME/.p10k.zsh"
assert_symlink_target "p10k target"         "$HOME/.p10k.zsh"    "zsh/p10k.zsh"

assert_symlink        "tmux.conf symlink"   "$HOME/.tmux.conf"
assert_symlink_target "tmux.conf target"    "$HOME/.tmux.conf"   "tmux/tmux.conf"

assert_symlink        "gitconfig symlink"   "$HOME/.gitconfig"
assert_symlink_target "gitconfig target"    "$HOME/.gitconfig"   "git/gitconfig"

assert_symlink        "gitignore symlink"   "$HOME/.gitignore_global"
assert_symlink_target "gitignore target"    "$HOME/.gitignore_global" "git/globalgitignore"

assert_symlink        "nvim config symlink" "$HOME/.config/nvim"
assert_symlink_target "nvim config target"  "$HOME/.config/nvim" "nvim"

assert_file_exists    "fzf keybindings installed" "$HOME/.fzf.zsh"

# ─── Ghostty must NOT be installed on Linux ───────────────────────────────────

echo ""
echo "── Platform guards ───────────────────────────────────────────────────────"

if [[ "$(uname -s)" == "Linux" ]]; then
  assert_not_exists "ghostty not installed on Linux" "$HOME/.config/ghostty/config"
else
  echo "    [skip] ghostty Linux guard check (not on Linux)"
fi

# ─── Config correctness ───────────────────────────────────────────────────────

echo ""
echo "── Config correctness ────────────────────────────────────────────────────"

assert_cmd_output \
  "git config is readable" \
  "user.name" \
  git config -f "$HOME/.gitconfig" --list

assert_cmd_no_output \
  "gitconfig excludesfile has no hardcoded /Users/ path" \
  "/Users/" \
  git config -f "$HOME/.gitconfig" core.excludesfile

# ─── Config parsing ───────────────────────────────────────────────────────────

echo ""
echo "── Config parsing ────────────────────────────────────────────────────────"

if command -v tmux &>/dev/null; then
  if tmux -f "$HOME/.tmux.conf" start-server \; kill-server 2>/dev/null; then
    pass "tmux config parses cleanly"
  else
    fail "tmux config failed to parse"
  fi
else
  fail "tmux not installed — cannot check config"
fi

# ─── Installed tools ──────────────────────────────────────────────────────────

echo ""
echo "── Installed tools ───────────────────────────────────────────────────────"

assert_cmd_exists "neovim installed"        nvim
assert_cmd_exists "lazygit installed"       lazygit
assert_cmd_exists "diff-so-fancy installed" diff-so-fancy
assert_cmd_exists "fzf installed"           fzf
assert_cmd_exists "ripgrep installed"       rg
assert_cmd_exists "jq installed"            jq
assert_cmd_exists "btop installed"          btop

assert_file_exists "pixi installed" "$HOME/.pixi/bin/pixi"

# ─── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "──────────────────────────────────────────────────────────────────────────"
if [[ $_failures -eq 0 ]]; then
  echo "All assertions passed."
  exit 0
else
  echo "$_failures assertion(s) failed."
  exit 1
fi
