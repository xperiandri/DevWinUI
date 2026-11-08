#requires -Version 7
# Links .claude/skills to .github/skills so Claude Code discovers the repository skills.
# Git cannot store a Windows junction, and a committed symlink only checks out as a real link with core.symlinks=true plus Developer Mode,
# so the link is created locally and git-ignored. A junction needs no elevation on Windows; elsewhere a relative symlink is used.
# The script only creates the link: it never deletes or replaces anything.

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$link = Join-Path $repositoryRoot '.claude/skills'
$target = Join-Path $repositoryRoot '.github/skills'

if (-not (Test-Path -LiteralPath $target)) {
    throw "Cannot link: '$target' does not exist."
}

if (Test-Path -LiteralPath $link) {
    $existing = Get-Item -LiteralPath $link -Force
    $kind = if ($existing.LinkType) { "$($existing.LinkType) to $($existing.Target -join ', ')" } else { 'a real directory' }
    Write-Host "Nothing to do: '$link' already exists ($kind)."
    return
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $link) | Out-Null

if ($IsWindows) {
    New-Item -ItemType Junction -Path $link -Target $target | Out-Null
}
else {
    New-Item -ItemType SymbolicLink -Path $link -Target '../.github/skills' | Out-Null
}

Write-Host "Linked '$link' to '$target'."
