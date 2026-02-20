#! /bin/bash
set -u          # die on undeclared vars
set -o pipefail # die on pipe failures
set -e          # die on error

DOTFILES=$(pwd -P)

# ─── Flags ────────────────────────────────────────────────────────────────────

DRY_RUN=false
SKIP_DOWNLOADS=false

_parse_args() {
  local args=()
  for arg in "$@"; do
    case "$arg" in
      --dry-run)        DRY_RUN=true ;;
      --skip-downloads) SKIP_DOWNLOADS=true ;;
      --help|-h)        usage ;;
      -*) echo "Unknown flag: $arg"; usage ;;
      *)  args+=("$arg") ;;
    esac
  done
  set -- "${args[@]+"${args[@]}"}"
  COMPONENTS=("$@")
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }

log()     { echo "==> $*"; }
log_sub() { echo "    $*"; }

# Run a command, or print what would be run in dry-run mode.
run_cmd() {
  if $DRY_RUN; then
    echo "    [dry-run] would run: $*"
  else
    "$@"
  fi
}

# Run a network/download command, skipping if --dry-run or --skip-downloads.
run_download() {
  if $DRY_RUN; then
    echo "    [dry-run] would download/fetch: $*"
  elif $SKIP_DOWNLOADS; then
    echo "    [skip-downloads] skipping: $*"
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

# ─── Packages ─────────────────────────────────────────────────────────────────

install_packages() {
  log "Installing packages..."

  if is_macos; then
    run_cmd brew install \
      zsh neovim fzf diff-so-fancy jq ripgrep tree \
      ccls npm lua-language-server lazygit btop ghostty

  elif is_linux; then
    log_sub "Running: apt-get update"
    run_cmd sudo apt-get update -qq

    log_sub "Running: apt-get install zsh neovim tmux fzf jq ripgrep btop npm ..."
    run_cmd sudo apt-get install -y \
      zsh neovim tmux curl wget git build-essential \
      fzf jq ripgrep tree btop npm

    _install_lazygit_linux
    _install_nvtop_linux
    _install_diff_so_fancy_linux
  fi

  log_sub "Packages done"
}

_install_lazygit_linux() {
  if command -v lazygit &>/dev/null; then
    log_sub "lazygit already installed, skipping"
    return
  fi
  log_sub "Downloading lazygit from GitHub releases..."
  run_download bash -c '
    version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
      | grep "\"tag_name\"" | cut -d "\"" -f4 | sed "s/v//")
    echo "    lazygit version: $version"
    curl -Lo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
    tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
    echo "    lazygit installed to /usr/local/bin/lazygit"
  '
}

_install_nvtop_linux() {
  if command -v nvtop &>/dev/null; then
    log_sub "nvtop already installed, skipping"
    return
  fi
  log_sub "Running: apt-get install nvtop"
  run_cmd sudo apt-get install -y nvtop \
    || log_sub "nvtop not available in apt, skipping (install manually if needed)"
}

_install_diff_so_fancy_linux() {
  if command -v diff-so-fancy &>/dev/null; then
    log_sub "diff-so-fancy already installed, skipping"
    return
  fi
  log_sub "Running: npm install -g diff-so-fancy"
  run_download sudo npm install -g diff-so-fancy
}

# ─── Pixi ─────────────────────────────────────────────────────────────────────

install_pixi() {
  log "Installing pixi..."
  if command -v pixi &>/dev/null || [[ -x "$HOME/.pixi/bin/pixi" ]]; then
    log_sub "pixi already installed, skipping"
    return
  fi
  log_sub "Downloading pixi installer..."
  run_download bash -c 'curl -fsSL https://pixi.sh/install.sh | bash'
  log_sub "pixi done"
}

# ─── Zsh ──────────────────────────────────────────────────────────────────────

install_zsh() {
  log "Installing zsh setup..."

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log_sub "Downloading and installing oh-my-zsh..."
    run_download bash -c \
      'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    log_sub "oh-my-zsh done"
  else
    log_sub "oh-my-zsh already installed, skipping"
  fi

  local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ ! -d "$p10k_dir" ]]; then
    log_sub "Cloning powerlevel10k theme..."
    run_download git clone --depth=1 \
      https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    log_sub "powerlevel10k done"
  else
    log_sub "powerlevel10k already installed, skipping"
  fi

  log_sub "Linking zsh configs..."
  link_file "$DOTFILES/zsh/zshrc"    "$HOME/.zshrc"
  link_file "$DOTFILES/zsh/p10k.zsh" "$HOME/.p10k.zsh"

  local theme_src="$DOTFILES/zsh/lambda-color.zsh-theme"
  local theme_dst="$HOME/.oh-my-zsh/custom/themes/lambda-color.zsh-theme"
  if [[ -f "$theme_src" ]]; then
    link_file "$theme_src" "$theme_dst"
  fi

  _install_fzf_keybindings
}

_install_fzf_keybindings() {
  log_sub "Setting up fzf key bindings..."
  if is_macos; then
    run_cmd "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
  elif is_linux; then
    # Ubuntu 24.04's fzf apt package omits key-bindings.zsh in some security
    # updates. Try the apt path first, then fall back to upstream.
    local fzf_script="/usr/share/doc/fzf/examples/key-bindings.zsh"
    if [[ -f "$fzf_script" ]]; then
      link_file "$fzf_script" "$HOME/.fzf.zsh"
    else
      log_sub "fzf apt examples missing, downloading key-bindings from upstream..."
      run_download curl -fsSL \
        https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh \
        -o "$HOME/.fzf.zsh"
      log_sub "fzf key-bindings done"
    fi
  fi
}

# ─── Git ──────────────────────────────────────────────────────────────────────

install_git() {
  log "Linking git configs..."
  link_file "$DOTFILES/git/gitconfig"       "$HOME/.gitconfig"
  link_file "$DOTFILES/git/globalgitignore" "$HOME/.gitignore_global"
}

# ─── Tmux ─────────────────────────────────────────────────────────────────────

install_tmux() {
  log "Linking tmux config..."
  link_file "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
}

# ─── Neovim ───────────────────────────────────────────────────────────────────

install_nvim() {
  log "Linking nvim config..."
  run_cmd mkdir -p "$HOME/.config"
  link_file "$DOTFILES/nvim" "$HOME/.config/nvim"
}

# ─── Ghostty (macOS only) ─────────────────────────────────────────────────────

install_ghostty() {
  if ! is_macos; then
    log "Skipping ghostty (not supported on Linux)"
    return
  fi
  log "Linking ghostty config..."
  run_cmd mkdir -p "$HOME/.config/ghostty"
  link_file "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
}

# ─── Dispatcher ───────────────────────────────────────────────────────────────

ALL_COMPONENTS=(packages pixi zsh git tmux nvim ghostty)

usage() {
  echo "Usage: $0 [flags] [component...]"
  echo ""
  echo "Flags:"
  echo "  --dry-run          Print what would be done, make no changes"
  echo "  --skip-downloads   Skip network downloads (apt still runs)"
  echo ""
  echo "Components: ${ALL_COMPONENTS[*]}"
  echo ""
  echo "If no components are given, all are installed."
  exit 1
}

main() {
  _parse_args "$@"

  if $DRY_RUN;        then log "DRY RUN — no changes will be made"; fi
  if $SKIP_DOWNLOADS; then log "SKIP DOWNLOADS — network fetches will be skipped"; fi

  local components=("${COMPONENTS[@]+"${COMPONENTS[@]}"}")
  if [[ ${#components[@]} -eq 0 ]]; then
    components=("${ALL_COMPONENTS[@]}")
  fi

  for component in "${components[@]}"; do
    case "$component" in
      packages) install_packages ;;
      pixi)     install_pixi ;;
      zsh)      install_zsh ;;
      git)      install_git ;;
      tmux)     install_tmux ;;
      nvim)     install_nvim ;;
      ghostty)  install_ghostty ;;
      *)        echo "Unknown component: $component"; usage ;;
    esac
  done

  log "All done."
}

main "$@"
