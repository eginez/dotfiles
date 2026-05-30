#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$DryRun,
    [Parameter(Mandatory = $true)]
    [ValidateSet('claude', 'opencode', 'all')]
    [string]$Target
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
$SkillsRoot = Join-Path $RepoRoot 'agents\skills'

$ClaudeSkillsDir = if ($env:CLAUDE_SKILLS_DIR) {
    $env:CLAUDE_SKILLS_DIR
} else {
    Join-Path $env:USERPROFILE '.claude\skills'
}

$OpenCodeSkillsDir = if ($env:OPENCODE_SKILLS_DIR) {
    $env:OPENCODE_SKILLS_DIR
} else {
    Join-Path $env:APPDATA 'opencode\skills'
}

function log {
    Write-Host "==> $args"
}

function log-sub {
    Write-Host "    $args"
}

function run-cmd {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action,
        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    if ($DryRun) {
        Write-Host "    [dry-run] would run: $Description"
        return
    }

    & $Action
}

function usage {
    Write-Host "Usage: .\install-agents.ps1 -Target <claude|opencode|all> [-DryRun]"
    Write-Host ""
    Write-Host "Installs all tracked agent skills from agents\skills into global harness directories."
    exit 1
}

function get-skill-directories {
    if (-not (Test-Path $SkillsRoot -PathType Container)) {
        throw "Skills root not found: $SkillsRoot"
    }

    $dirs = Get-ChildItem -Path $SkillsRoot -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
        Sort-Object Name

    if ($dirs.Count -eq 0) {
        throw "No skills found under $SkillsRoot"
    }

    return $dirs
}

function ensure-target-dir {
    param([string]$Path)

    log-sub "Ensuring $Path exists"
    run-cmd -Description "New-Item -ItemType Directory -Path '$Path' -Force" -Action {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function link-skill-dir {
    param(
        [string]$Source,
        [string]$DestinationRoot
    )

    $name = Split-Path $Source -Leaf
    $destination = Join-Path $DestinationRoot $name

    if (Test-Path $destination) {
        $existing = Get-Item $destination -Force
        if ($existing.LinkType) {
            log-sub "Replacing link $destination"
            run-cmd -Description "Remove-Item '$destination' -Force -Recurse" -Action {
                Remove-Item $destination -Force -Recurse
            }
        } else {
            throw "Refusing to overwrite non-link path: $destination"
        }
    }

    log-sub "Linking $Source -> $destination"
    run-cmd -Description "New-Item -ItemType Junction -Path '$destination' -Target '$Source'" -Action {
        New-Item -ItemType Junction -Path $destination -Target $Source | Out-Null
    }
}

function install-to-target {
    param(
        [string]$Label,
        [string]$DestinationRoot,
        [System.IO.DirectoryInfo[]]$SkillDirs
    )

    log "Installing agent skills for $Label..."
    ensure-target-dir $DestinationRoot
    foreach ($skillDir in $SkillDirs) {
        link-skill-dir -Source $skillDir.FullName -DestinationRoot $DestinationRoot
    }
}

function main {
    $skillDirs = get-skill-directories

    switch ($Target) {
        'claude' {
            install-to-target -Label 'claude' -DestinationRoot $ClaudeSkillsDir -SkillDirs $skillDirs
        }
        'opencode' {
            install-to-target -Label 'opencode' -DestinationRoot $OpenCodeSkillsDir -SkillDirs $skillDirs
        }
        'all' {
            install-to-target -Label 'claude' -DestinationRoot $ClaudeSkillsDir -SkillDirs $skillDirs
            install-to-target -Label 'opencode' -DestinationRoot $OpenCodeSkillsDir -SkillDirs $skillDirs
        }
        default {
            usage
        }
    }

    log 'Agent skills install done.'
}

main
