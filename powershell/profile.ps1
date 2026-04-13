# ─── PATH ─────────────────────────────────────────────────────────────────────

$env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
$env:PATH = "$env:USERPROFILE\.pixi\bin;$env:PATH"
$env:PATH = "$env:USERPROFILE\.opencode\bin;$env:PATH"
$env:PATH = "$env:USERPROFILE\bin;$env:PATH"
$env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"

# ─── Environment ──────────────────────────────────────────────────────────────

$env:EDITOR = 'nvim'
$env:USER   = $env:USERNAME   # diff-so-fancy compat

# ─── Aliases ──────────────────────────────────────────────────────────────────

Set-Alias -Name g   -Value git     -Option AllScope
Set-Alias -Name kct -Value kubectl -Option AllScope

function c   { Set-Location @args }
function fbn { Get-ChildItem -Recurse -Filter $args[0] }
function gw  { & .\gradlew @args }

# ─── Docker helpers ───────────────────────────────────────────────────────────

function dkrRun {
    param([string]$Entrypoint, [string]$Image)
    docker run -it --rm --entrypoint $Entrypoint $Image
}

function dkrGpu { docker run -it --rm --gpus all @args }

function did {
    param([string]$Name = '')
    if ($Name -eq '') {
        docker ps | fzf -m | ForEach-Object { ($_ -split '\s+')[0] }
    } else {
        docker ps -q --filter "name=$Name"
    }
}

# ─── Quick queries (-o opencode, -c claude) ───────────────────────────────────

function qq {
    param(
        [switch]$o,
        [switch]$c,
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Query
    )
    if ($Query.Count -eq 0) {
        Write-Host "Usage: qq [-o|-c] <your question>"
        return
    }
    if ($c) {
        Write-Host 'not implemented yet'
    } else {
        $env:OPENCODE_DISABLE_DEFAULT_PLUGINS       = '1'
        $env:OPENCODE_DISABLE_FILEWATCHER           = '1'
        $env:OPENCODE_DISABLE_AUTOCOMPACT           = '1'
        $env:OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX = '500'
        opencode run --pure --log-level ERROR -m local/qwen35-int4 @Query
    }
}

# ─── Private / local overrides ────────────────────────────────────────────────

$_privatePwsh = "$env:USERPROFILE\.private.ps1"
if (Test-Path $_privatePwsh) { . $_privatePwsh }
Remove-Variable _privatePwsh
