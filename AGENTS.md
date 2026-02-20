# Dotfiles — Agent Context

This document is written for LLMs. It describes what this repo is, how it is structured, what each file does, and what decisions were made and why.

---

## What this repo is

A personal dotfiles setup for two platforms:
- **macOS** (primary development machine)
- **Linux — NVIDIA DGX Spark** (GPU workstation, Ubuntu 24.04)

The goal is a single repo that works on both platforms. Platform-specific behaviour is handled with OS guards (`is_macos` / `is_linux` functions), not separate files.

---

## Repo structure

```
dotfiles/
├── install.sh              # Main install script (see below)
├── AGENTS.md               # This file
├── git/
│   ├── gitconfig           # Git config (symlinked to ~/.gitconfig)
│   └── globalgitignore     # Global gitignore (symlinked to ~/.gitignore_global)
├── ghostty/
│   └── config              # Ghostty terminal config (macOS only)
├── nvim/                   # Full Neovim config (LazyVim-based)
│   ├── init.lua
│   ├── lazy-lock.json
│   ├── lazyvim.json
│   └── lua/
│       ├── config/         # lazy.lua, options.lua, keymaps.lua, autocmds.lua
│       └── plugins/        # Custom plugin overrides (example.lua)
├── tmux/
│   └── tmux.conf           # Tmux config (symlinked to ~/.tmux.conf)
├── zsh/
│   ├── zshrc               # Main zsh config (symlinked to ~/.zshrc)
│   ├── p10k.zsh            # Powerlevel10k prompt config
│   └── lambda-color.zsh-theme  # Alternative zsh theme
└── test/
    ├── Dockerfile          # Ubuntu 24.04 test image
    ├── run.sh              # Runs both test passes in Docker
    └── assert.sh           # Standalone assertion suite
```

---

## install.sh

The main entry point. Run from the repo root:

```bash
./install.sh                        # install everything
./install.sh zsh git tmux           # install specific components
./install.sh --dry-run              # print what would happen, do nothing
./install.sh --skip-downloads       # skip network fetches (apt still runs)
./install.sh --dry-run zsh nvim     # combine flags and components
```

### Flags

| Flag | Effect |
|---|---|
| `--dry-run` | All side-effecting commands are printed but not run. Symlinks are not created, packages are not installed. |
| `--skip-downloads` | Only network downloads are skipped (lazygit, pixi, diff-so-fancy, fzf keybindings fallback). `apt-get` still runs. |

### Components (in install order)

| Component | What it does |
|---|---|
| `packages` | Installs all system packages via brew (macOS) or apt (Linux) |
| `pixi` | Installs [pixi](https://pixi.sh) package manager via curl |
| `zsh` | Installs oh-my-zsh, powerlevel10k, links zshrc + p10k.zsh, sets up fzf keybindings |
| `git` | Symlinks gitconfig and globalgitignore |
| `tmux` | Symlinks tmux.conf |
| `nvim` | Symlinks the nvim/ directory to ~/.config/nvim |
| `ghostty` | Symlinks ghostty config (macOS only, skipped on Linux with a message) |

### Helper functions

- `is_macos` / `is_linux` — OS detection
- `log` / `log_sub` — formatted output (`==>` and `    ` prefix); all output is always visible, commands stream their output directly so the user can see progress in real time
- `link_file src dst` — creates `ln -sf`, backs up existing non-symlink files to `.bak`
- `run_cmd <cmd>` — runs command, or prints `[dry-run] would run:` if `DRY_RUN=true`
- `run_download <cmd>` — runs command, or prints skip message if `DRY_RUN=true` or `SKIP_DOWNLOADS=true`

### Output philosophy

Nothing is silenced. Every command streams its output directly to the terminal. The `log` / `log_sub` markers act as signposts so you always know which step you're in, even when a long apt or npm output is scrolling past. Example of what a real install looks like:

```
==> Installing packages...
    Running: apt-get update
    Running: apt-get install zsh neovim tmux fzf jq ripgrep btop npm ...
Reading package lists...
Get:1 ... [every package streams as it downloads]
Setting up neovim ...
    Downloading lazygit from GitHub releases...
    lazygit version: 0.44.1
    lazygit installed to /usr/local/bin/lazygit
    Packages done
==> Installing pixi...
    Downloading pixi installer...
    pixi done
==> All done.
```

### Linux-specific installs

These are handled by private helper functions called from `install_packages`:

- **`_install_lazygit_linux`** — downloads latest lazygit binary from GitHub releases, installs to `/usr/local/bin`
- **`_install_nvtop_linux`** — installs `nvtop` (GPU monitor) via apt; gracefully skips if not available
- **`_install_diff_so_fancy_linux`** — installs `diff-so-fancy` via npm globally

### fzf keybindings on Linux (known issue)

Ubuntu 24.04's fzf apt package (`0.44.1-1ubuntu0.3`) lists `key-bindings.zsh` in its manifest but does not actually install it to disk — a regression in a security update. The script handles this with a fallback:

1. Try `/usr/share/doc/fzf/examples/key-bindings.zsh` (the expected apt path)
2. If missing, download directly from `https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh`

---

## zsh/zshrc

The zsh config is designed to work on both platforms from a single file. Key structure:

### PATH (platform-aware)
```zsh
export PATH="$HOME/bin:/usr/local/bin:$PATH"
# macOS only:
export PATH="/opt/homebrew/bin:/opt/:$PATH"
```

### OS guards
All macOS-specific code is wrapped in `is_macos`:
- Homebrew PATH and `HOMEBREW_NO_AUTO_UPDATE`
- iTerm2 shell integration
- SDKMAN setup
- Emacs.app functions (`fn_emacs`, `alias em`, `alias memacs`)
- `alias ownusr` (macOS `/usr/local` ownership hack)

Linux-specific settings are wrapped in `is_linux`:
- `export TERM=xterm-256color` — Ghostty sets `TERM=xterm-ghostty` which Ubuntu doesn't recognize, causing broken keys (backspace, tab). Force `xterm-256color` on Linux.
- `alias top=btop`
- `alias gpu='watch -n1 nvidia-smi'`

### Pixi
```zsh
eval "$(pixi completion --shell zsh)"
```
Sourced if pixi is available. Provides tab completion for pixi commands.

### Docker helpers
- `dkrRun <entrypoint> <image>` — run container with custom entrypoint
- `dkrGpu <docker args>` — run container with `--gpus all` (Linux GPU workloads)
- `did [name]` — get container ID interactively via fzf, or by name filter

### Conda helpers
- `git_conda_activate` — activates a conda env named after the current git repo
- `git_conda_create [python_version]` — creates a conda env named after the current git repo

### Private overrides
```zsh
[[ -f ~/.private.zshrc ]] && source ~/.private.zshrc
```
A local file for secrets and machine-specific config that is not committed.

---

## git/gitconfig

Standard git config. Key points:
- `core.excludesfile = ~/.gitignore_global` — uses `~` (not hardcoded path), works on both platforms
- `core.pager = diff-so-fancy | less --tabs=4 -RFX` — pretty diffs
- `core.editor = nvim`
- `init.defaultBranch = main`

---

## tmux/tmux.conf

Built for a keyboard-heavy workflow that mirrors Neovim bindings.

| Setting | Value |
|---|---|
| Prefix | `C-a` (not default `C-b`) |
| Mouse | on |
| Terminal | `tmux-256color` with true color |
| Escape time | 0 (critical for Neovim — removes insert-mode delay) |
| Base index | 1 (windows and panes start at 1) |
| Split horizontal | `prefix + |` |
| Split vertical | `prefix + -` |
| Pane navigation | `prefix + h/j/k/l` |
| Pane resize | `prefix + H/J/K/L` (repeatable) |
| Copy mode | vi; `v` to select, `y` to yank |
| Reload config | `prefix + r` |
| Status bar | Catppuccin-style colors; left: session name; right: hostname + datetime |

---

## nvim/

Uses [LazyVim](https://lazyvim.org) as the base configuration. The `nvim/` directory is symlinked wholesale to `~/.config/nvim`.

- `init.lua` — bootstraps lazy.nvim, then calls `require("config.lazy")`
- `lua/config/lazy.lua` — sets up lazy.nvim with LazyVim + custom plugins
- `lua/config/options.lua` — additional options (currently empty, LazyVim defaults apply)
- `lua/config/keymaps.lua` — custom keymaps
- `lua/config/autocmds.lua` — custom autocommands
- `lua/plugins/` — plugin overrides and additions (currently only `example.lua`)

---

## ghostty/config

Ghostty terminal keybindings (macOS only):

| Binding | Action |
|---|---|
| `ctrl+n` | New split (down) |
| `ctrl+h/l/k/j` | Navigate splits |
| `ctrl+tab` | Next tab |

---

## test/

The test suite runs inside Docker to validate a clean install from scratch.

### test/Dockerfile

- Base: `ubuntu:24.04`
- Minimal bootstrap: `sudo curl git` only (nothing else pre-installed)
- Non-root user `testuser` with passwordless sudo
- Copies the full dotfiles repo in

### test/run.sh

Runs two passes:

**Pass 1 — Full install** (real network, real downloads):
```bash
docker run ... bash -c "./install.sh && ./test/assert.sh"
```

**Pass 2 — Dry-run** (no side effects):
```bash
docker run ... bash -c "./install.sh --dry-run && test ! -L ~/.zshrc && ..."
```

Options:
```bash
./test/run.sh             # build image + both passes
./test/run.sh --no-build  # skip docker build, use cached image
```

### test/assert.sh

25 assertions across 4 categories. Can be run standalone on a real machine after install:
```bash
bash test/assert.sh
```

Categories:
1. **Symlinks** — all config files are symlinks pointing to the right source
2. **Platform guards** — ghostty config does NOT exist on Linux
3. **Config correctness** — git config readable, no hardcoded `/Users/` paths
4. **Installed tools** — nvim, lazygit, diff-so-fancy, fzf, rg, jq, btop, pixi

---

## Known issues / gotchas

| Issue | Status |
|---|---|
| Ubuntu fzf apt package omits `key-bindings.zsh` (security update regression) | Fixed: script falls back to upstream download |
| `nvtop` may not be available in apt on some Ubuntu versions | Handled: script prints a warning and continues |
| Ghostty is macOS-only | Handled: `install_ghostty` returns early on Linux |
| `diff-so-fancy` requires npm to be installed first | npm is in the apt package list, installed before `_install_diff_so_fancy_linux` is called |
| Ghostty terminal + SSH to Linux breaks keys | Fixed: zshrc forces `TERM=xterm-256color` on Linux |

---

## What to do on a fresh DGX Spark

```bash
git clone <this-repo> ~/src/dotfiles
cd ~/src/dotfiles
bash install.sh
chsh -s $(which zsh)   # set zsh as default shell
```

Then start a new shell session.
