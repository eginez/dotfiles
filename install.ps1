#Requires -Version 5.1
<#
.SYNOPSIS
    Windows dotfiles installer - mirrors install.sh for macOS/Linux.

.DESCRIPTION
    Installs packages via scoop, links config files, and sets up the
    PowerShell profile. Supports --dry-run and --skip-downloads modes.

.PARAMETER DryRun
    Print what would be done without making any changes.

.PARAMETER SkipDownloads
    Skip network downloads (scoop/pixi installs are also skipped).

.PARAMETER Components
    One or more components to install. If omitted, all are installed.
    Valid values: packages, pixi, powershell, git, nvim, ghostty, lazygit

.EXAMPLE
    .\install.ps1
    .\install.ps1 -DryRun
    .\install.ps1 git nvim
    .\install.ps1 -SkipDownloads powershell git nvim
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$SkipDownloads,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Components = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DOTFILES = $PSScriptRoot

# Ensure scoop shims and pixi bin are on PATH for this session
$scoopShims = Join-Path $env:USERPROFILE 'scoop\shims'
$pixiBin    = Join-Path $env:USERPROFILE '.pixi\bin'
foreach ($p in @($scoopShims, $pixiBin)) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
        $env:PATH = "$p;$env:PATH"
    }
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

function log     { Write-Host "==> $args" }
function log-sub { Write-Host "    $args" }

# Run a command, or print what would be run in dry-run mode.
function run-cmd {
    if ($DryRun) {
        Write-Host "    [dry-run] would run: $args"
        return
    }
    & $args[0] $args[1..($args.Length - 1)]
}

# Run a network/download command, skipping if -DryRun or -SkipDownloads.
function run-download {
    if ($DryRun) {
        Write-Host "    [dry-run] would download/fetch: $args"
        return
    }
    if ($SkipDownloads) {
        Write-Host "    [skip-downloads] skipping: $args"
        return
    }
    & $args[0] $args[1..($args.Length - 1)]
}

# Returns $true if Windows Developer Mode is enabled (allows unprivileged symlinks).
function _developer-mode-enabled {
    $val = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
        -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue
    return ($val -and $val.AllowDevelopmentWithoutDevLicense -eq 1)
}

# Link a file or directory; backs up any existing non-link to .bak first.
#   Directories  -> junction  (no elevation or Developer Mode needed)
#   Files        -> symlink   (requires Developer Mode or admin elevation)
#                  copy       (fallback if neither available; re-run install after edits)
function link-file {
    param(
        [string]$Src,
        [string]$Dst
    )
    if ((Test-Path $Dst) -and -not ((Get-Item $Dst -Force).LinkType)) {
        log-sub "Backing up $Dst -> ${Dst}.bak"
        if (-not $DryRun) { Move-Item $Dst "${Dst}.bak" -Force }
    }
    log-sub "Linking $Src -> $Dst"
    if ($DryRun) { return }

    # Remove stale entry at destination
    if (Test-Path $Dst) { Remove-Item $Dst -Force -Recurse }

    if (Test-Path $Src -PathType Container) {
        # Directory junction - transparent to apps, no elevation required
        & cmd /c mklink /J "$Dst" "$Src" | Out-Null
    } else {
        # File: symlink if Developer Mode is on, otherwise copy
        if (_developer-mode-enabled) {
            New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -Force | Out-Null
        } else {
            Copy-Item $Src $Dst -Force
            log-sub "Note: copied (no symlink) -- enable Developer Mode for live edits"
        }
    }
}

# ─── Packages ─────────────────────────────────────────────────────────────────

function install-packages {
    log "Installing packages..."

    # Install scoop if not present
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        log-sub "Installing scoop..."
        run-download powershell -Command {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        }
    } else {
        log-sub "scoop already installed, skipping"
    }

    log-sub "Adding scoop extras bucket..."
    run-cmd scoop bucket add extras

    log-sub "Installing core packages via scoop..."
    run-cmd scoop install neovim ripgrep jq fzf lazygit nodejs btop

    log-sub "Installing diff-so-fancy via npm..."
    run-download npm install -g diff-so-fancy

    log-sub "Packages done"
}

# ─── Pixi ─────────────────────────────────────────────────────────────────────

function install-pixi {
    log "Installing pixi..."
    if ((Get-Command pixi -ErrorAction SilentlyContinue) -or
        (Test-Path "$env:USERPROFILE\.pixi\bin\pixi.exe")) {
        log-sub "pixi already installed, skipping"
        return
    }
    log-sub "Downloading pixi installer..."
    run-download powershell -Command {
        Invoke-RestMethod https://pixi.sh/install.ps1 | Invoke-Expression
    }
    log-sub "pixi done"
}

# ─── PowerShell ───────────────────────────────────────────────────────────────

function install-powershell {
    log "Setting up PowerShell profile..."

    # oh-my-posh (prompt theming - equivalent of Powerlevel10k)
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        log-sub "Installing oh-my-posh..."
        run-download scoop install oh-my-posh
    } else {
        log-sub "oh-my-posh already installed, skipping"
    }

    # PSFzf (fzf integration for PSReadLine)
    if (-not (Get-Module -ListAvailable -Name PSFzf)) {
        log-sub "Installing PSFzf module..."
        if (-not $DryRun -and -not $SkipDownloads) {
            # Bootstrap NuGet provider (required by PS5.1's old PowerShellGet)
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
            Install-Module PSFzf -Scope CurrentUser -Force -AllowClobber
        } elseif ($DryRun) {
            log-sub "[dry-run] would run: Install-Module PSFzf -Scope CurrentUser -Force -AllowClobber"
        }
    } else {
        log-sub "PSFzf already installed, skipping"
    }

    # Ensure profile directory exists
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path $profileDir)) {
        log-sub "Creating profile directory: $profileDir"
        if (-not $DryRun) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    }

    log-sub "Linking PowerShell profile..."
    link-file "$DOTFILES\powershell\profile.ps1" $PROFILE

    log-sub "PowerShell profile done"
}

# ─── Git ──────────────────────────────────────────────────────────────────────

function install-git {
    log "Linking git configs..."
    link-file "$DOTFILES\git\gitconfig"       "$env:USERPROFILE\.gitconfig"
    link-file "$DOTFILES\git\globalgitignore" "$env:USERPROFILE\.gitignore_global"
}

# ─── Neovim ───────────────────────────────────────────────────────────────────

function install-nvim {
    log "Linking nvim config..."
    # On Windows, nvim config lives at %LOCALAPPDATA%\nvim (not ~/.config/nvim)
    $nvimConfig = "$env:LOCALAPPDATA\nvim"
    link-file "$DOTFILES\nvim" $nvimConfig
}

# ─── Ghostty (not supported on Windows) ───────────────────────────────────────

function install-ghostty {
    log "Skipping ghostty (not supported on Windows)"
}

# ─── Lazygit ──────────────────────────────────────────────────────────────────

function install-lazygit {
    log "Linking lazygit config..."
    # Lazygit on Windows reads from %LOCALAPPDATA%\lazygit\config.yml by default.
    $lazygitDir = "$env:LOCALAPPDATA\lazygit"
    if (-not (Test-Path $lazygitDir)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $lazygitDir -Force | Out-Null }
    }
    link-file "$DOTFILES\lazygit\config.yml" "$lazygitDir\config.yml"
}

# ─── Dispatcher ───────────────────────────────────────────────────────────────

$ALL_COMPONENTS = @('packages', 'pixi', 'powershell', 'git', 'nvim', 'ghostty', 'lazygit')

function usage {
    Write-Host "Usage: .\install.ps1 [-DryRun] [-SkipDownloads] [component...]"
    Write-Host ""
    Write-Host "Flags:"
    Write-Host "  -DryRun          Print what would be done, make no changes"
    Write-Host "  -SkipDownloads   Skip network downloads"
    Write-Host ""
    Write-Host "Components: $($ALL_COMPONENTS -join ', ')"
    Write-Host ""
    Write-Host "If no components are given, all are installed."
    exit 1
}

function main {
    if ($DryRun)        { log "DRY RUN - no changes will be made" }
    if ($SkipDownloads) { log "SKIP DOWNLOADS - network fetches will be skipped" }

    $toRun = if ($Components.Count -eq 0) { $ALL_COMPONENTS } else { $Components }

    foreach ($component in $toRun) {
        switch ($component) {
            'packages'   { install-packages }
            'pixi'       { install-pixi }
            'powershell' { install-powershell }
            'git'        { install-git }
            'nvim'       { install-nvim }
            'ghostty'    { install-ghostty }
            'lazygit'    { install-lazygit }
            default      { Write-Error "Unknown component: $component"; usage }
        }
    }

    log "All done."
}

main
