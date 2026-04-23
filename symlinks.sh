#! /bin/bash
set -u          # die on undeclared vars
set -o pipefail # die on pipe failures
set -e          # die on error

DRY_RUN=${DRY_RUN:-false}
DOTFILES_ROOT=${DOTFILES_ROOT:-}

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

log()     { echo "==> $*"; }
log_sub() { echo "    $*"; }

run_cmd() {
  if $DRY_RUN; then
    echo "    [dry-run] would run: $*"
  else
    "$@"
  fi
}

# Create a symlink; backs up any existing non-symlink file to .bak first.
link_file() {
  local src=$1 dst=$2
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    log_sub "Backing up $dst -> ${dst}.bak"
    run_cmd mv "$dst" "${dst}.bak"
  fi
  log_sub "Linking $src -> $dst"
  run_cmd ln -sf "$src" "$dst"
}

install_zsh_links() {
  link_file "$DOTFILES_ROOT/zsh/zshrc" "$HOME/.zshrc"
  link_file "$DOTFILES_ROOT/zsh/p10k.zsh" "$HOME/.p10k.zsh"

  local theme_src="$DOTFILES_ROOT/zsh/lambda-color.zsh-theme"
  local theme_dst="$HOME/.oh-my-zsh/custom/themes/lambda-color.zsh-theme"
  if [[ -f "$theme_src" ]]; then
    link_file "$theme_src" "$theme_dst"
  fi
}

install_git_links() {
  link_file "$DOTFILES_ROOT/git/gitconfig" "$HOME/.gitconfig"
  link_file "$DOTFILES_ROOT/git/globalgitignore" "$HOME/.gitignore_global"
}

install_tmux_links() {
  link_file "$DOTFILES_ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
}

install_nvim_link() {
  run_cmd mkdir -p "$HOME/.config"
  link_file "$DOTFILES_ROOT/nvim" "$HOME/.config/nvim"
}

install_ghostty_link() {
  if ! is_macos; then
    log "Skipping ghostty (not supported on Linux)"
    return
  fi
  run_cmd mkdir -p "$HOME/.config/ghostty"
  link_file "$DOTFILES_ROOT/ghostty/config" "$HOME/.config/ghostty/config"
}

install_symlinks() {
  if [[ -z "$DOTFILES_ROOT" ]]; then
    echo "DOTFILES_ROOT is required" >&2
    exit 1
  fi

  log "Linking dotfiles from $DOTFILES_ROOT..."
  install_zsh_links
  install_git_links
  install_tmux_links
  install_nvim_link
  install_ghostty_link
  log "Symlinks done"
}

usage() {
  echo "Usage: $0 [source-root]"
  echo ""
  echo "If no source root is given, the current directory is used."
  exit 1
}

main() {
  case "${1:-}" in
    -h|--help) usage ;;
  esac

  DOTFILES_ROOT=${1:-$(pwd -P)}
  install_symlinks
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
