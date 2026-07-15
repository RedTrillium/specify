#!/usr/bin/env pwsh

# L1 (inner-loop) gate runner
#
# Enforces the gates that .specify/memory/development-loops.md assigns to L1:
# secret detection (stack-agnostic, always on) plus format / typecheck / test
# (bound per-feature by /speckit-plan in .specify/loops.json).
#
# Technology-agnostic by design: this script is a MECHANISM. It never chooses a
# formatter or test runner - it runs whatever .specify/loops.json declares. An
# unbound gate is skipped with a notice, never silently passed.
#
# Usage: ./run-l1-gates.ps1 [OPTIONS]
#
# OPTIONS:
#   -File <path>    Run gates against a single file
#   -FromHook       Read Claude Code hook JSON from stdin, extract file_path
#   -Staged         Run gates against git staged files (pre-commit)
#   -Json           Emit machine-readable JSON result
#   -Help, -h       Show help message
#
# EXIT CODES:
#   0  all applicable gates passed (or were skipped as unbound)
#   2  a gate failed - blocking

[CmdletBinding()]
param(
    [string]$File,
    [switch]$FromHook,
    [switch]$Staged,
    [switch]$Json,
    [Alias('h')][switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Get-Content $PSCommandPath | Select-Object -Skip 1 -First 22 | ForEach-Object { $_ -replace '^# ?', '' }
    exit 0
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$ConfigPath = Join-Path $RepoRoot '.specify\loops.json'

$failures = New-Object System.Collections.ArrayList
$notices = New-Object System.Collections.ArrayList

# --- resolve target files -------------------------------------------------

$targets = New-Object System.Collections.ArrayList

if ($FromHook) {
    $raw = ''
    try { $raw = [Console]::In.ReadToEnd() } catch { $raw = '' }
    if (-not [string]::IsNullOrWhiteSpace($raw)) {
        try {
            $payload = $raw | ConvertFrom-Json
            $p = $null
            if ($payload.tool_response -and $payload.tool_response.PSObject.Properties['filePath']) {
                $p = $payload.tool_response.filePath
            }
            if (-not $p -and $payload.tool_input -and $payload.tool_input.PSObject.Properties['file_path']) {
                $p = $payload.tool_input.file_path
            }
            if ($p) { [void]$targets.Add($p) }
        } catch {
            # Malformed hook payload must never wedge the inner loop.
            exit 0
        }
    }
}
elseif ($Staged) {
    # Do not name this $staged: PowerShell variables are case-insensitive, so it
    # would overwrite the [switch]$Staged parameter and fail to coerce.
    # Do not redirect git's stderr here either: in PS 5.1 that wraps output lines
    # in ErrorRecords and trips $ErrorActionPreference='Stop' on a clean exit 0.
    $stagedFiles = & git -C $RepoRoot diff --cached --name-only --diff-filter=ACM
    foreach ($s in $stagedFiles) {
        if (-not [string]::IsNullOrWhiteSpace($s)) {
            [void]$targets.Add((Join-Path $RepoRoot $s))
        }
    }
}
elseif ($File) {
    [void]$targets.Add($File)
}

# Nothing to check is a pass, not a failure.
if ($targets.Count -eq 0) {
    if ($Json) { '{"result":"pass","gates":[],"reason":"no target files"}' }
    exit 0
}

# --- load config ----------------------------------------------------------

$cfg = $null
if (Test-Path $ConfigPath) {
    try { $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json } catch {
        [void]$notices.Add("loops.json is malformed - L1 gates cannot be read: $($_.Exception.Message)")
    }
}
else {
    [void]$notices.Add('.specify/loops.json not found - only secret scanning will run.')
}

function Get-ConfigValue($obj, [string]$name) {
    if ($null -eq $obj) { return $null }
    if (-not $obj.PSObject.Properties[$name]) { return $null }
    return $obj.$name
}

# --- gate: secret detection (stack-agnostic, always on) -------------------

$secretPatterns = @(
    @{ Name = 'AWS access key id';        Pattern = 'AKIA[0-9A-Z]{16}' },
    @{ Name = 'Private key block';        Pattern = '-----BEGIN [A-Z ]*PRIVATE KEY-----' },
    @{ Name = 'GitHub personal token';    Pattern = 'ghp_[A-Za-z0-9]{36}' },
    @{ Name = 'GitHub fine-grained PAT';  Pattern = 'github_pat_[A-Za-z0-9_]{22,}' },
    @{ Name = 'Anthropic API key';        Pattern = 'sk-ant-[A-Za-z0-9_\-]{20,}' },
    @{ Name = 'OpenAI-style API key';     Pattern = 'sk-[A-Za-z0-9]{32,}' },
    @{ Name = 'Slack token';              Pattern = 'xox[baprs]-[A-Za-z0-9-]{10,}' },
    @{ Name = 'Google API key';           Pattern = 'AIza[0-9A-Za-z_\-]{35}' },
    @{ Name = 'Azure storage AccountKey'; Pattern = 'AccountKey=[A-Za-z0-9+/=]{40,}' },
    @{ Name = 'Hardcoded credential';     Pattern = '(?i)\b(password|passwd|secret|api[_-]?key|apikey|access[_-]?token|auth[_-]?token)\b\s*[:=]\s*["''][^"''\s$<>{}]{8,}["'']' }
)

$scanCfg = Get-ConfigValue $cfg 'secretScan'
$scanEnabled = $true
if ($scanCfg -and $null -ne (Get-ConfigValue $scanCfg 'enabled')) { $scanEnabled = [bool]$scanCfg.enabled }

$excludes = @()
if ($scanCfg -and (Get-ConfigValue $scanCfg 'excludePaths')) { $excludes = @($scanCfg.excludePaths) }

$textish = @('.ps1', '.psm1', '.sh', '.bash', '.py', '.js', '.jsx', '.ts', '.tsx', '.cs', '.go', '.rs',
    '.java', '.rb', '.php', '.json', '.jsonc', '.yaml', '.yml', '.toml', '.ini', '.cfg', '.conf',
    '.env', '.xml', '.md', '.txt', '.sql', '.tf', '.tfvars', '.props', '.csproj', '.config')

if ($scanEnabled) {
    foreach ($t in $targets) {
        if (-not (Test-Path $t -PathType Leaf)) { continue }

        $full = (Resolve-Path $t).Path
        $rel = $full
        if ($full.StartsWith($RepoRoot, [StringComparison]::OrdinalIgnoreCase)) {
            $rel = $full.Substring($RepoRoot.Length).TrimStart('\', '/')
        }
        $relNorm = $rel -replace '\\', '/'

        $skip = $false
        foreach ($ex in $excludes) {
            if ($relNorm -ieq ($ex -replace '\\', '/')) { $skip = $true; break }
        }
        if ($skip) { continue }

        $ext = [System.IO.Path]::GetExtension($full)
        if ($ext -and ($textish -notcontains $ext.ToLower())) { continue }

        $lineNo = 0
        foreach ($line in (Get-Content -LiteralPath $full -ErrorAction SilentlyContinue)) {
            $lineNo++
            if ($line -match 'pragma:\s*allowlist secret') { continue }
            foreach ($sp in $secretPatterns) {
                if ($line -match $sp.Pattern) {
                    [void]$failures.Add("SECRET [$($sp.Name)] $relNorm`:$lineNo - remove it and use a managed secret store (Article V). Add 'pragma: allowlist secret' on the line only if this is a false positive.")
                    break
                }
            }
        }
    }
}

# --- gates: format / typecheck / test (bound by /speckit-plan) ------------

$l1 = Get-ConfigValue $cfg 'l1'
$fileArg = ($targets | ForEach-Object { '"{0}"' -f $_ }) -join ' '

function Invoke-Gate([string]$name, [string]$template) {
    if ([string]::IsNullOrWhiteSpace($template)) {
        [void]$notices.Add("L1 gate '$name' is UNBOUND - no command in .specify/loops.json. It is skipped, not passed. /speckit-plan must bind it when the stack is chosen.")
        return
    }
    $cmd = $template.Replace('{file}', $fileArg)
    Push-Location $RepoRoot
    try {
        $out = & cmd.exe /c $cmd 2>&1
        if ($LASTEXITCODE -ne 0) {
            [void]$failures.Add("L1 gate '$name' FAILED (exit $LASTEXITCODE): $cmd`n$($out -join [Environment]::NewLine)")
        }
    }
    catch {
        [void]$failures.Add("L1 gate '$name' errored: $($_.Exception.Message)")
    }
    finally { Pop-Location }
}

if ($l1) {
    Invoke-Gate 'format'    (Get-ConfigValue $l1 'format')
    Invoke-Gate 'typecheck' (Get-ConfigValue $l1 'typecheck')
    Invoke-Gate 'test'      (Get-ConfigValue $l1 'test')
}

# --- report ---------------------------------------------------------------

if ($Json) {
    $result = [ordered]@{
        result   = if ($failures.Count -gt 0) { 'fail' } else { 'pass' }
        failures = @($failures)
        notices  = @($notices)
    }
    ($result | ConvertTo-Json -Depth 4)
    if ($failures.Count -gt 0) { exit 2 }
    exit 0
}

if ($failures.Count -gt 0) {
    [Console]::Error.WriteLine("L1 gates failed (see .specify/memory/development-loops.md):")
    foreach ($f in $failures) { [Console]::Error.WriteLine("  - $f") }
    exit 2
}

if (-not $FromHook) {
    foreach ($n in $notices) { Write-Host "note: $n" -ForegroundColor DarkYellow }
    Write-Host "L1 gates passed." -ForegroundColor Green
}

exit 0
