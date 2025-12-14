#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Release script for git-tfs that creates a tag and triggers CI build

.DESCRIPTION
    This script helps create a release by:
    1. Getting the next version number
    2. Creating a git tag
    3. Pushing the tag to trigger GitHub Actions release build
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Version,

    [switch]$DryRun,

    [string]$Message = "",

    [switch]$SkipPush
)

# Validate version format
if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    Write-Error "Version must be in format X.Y.Z (e.g., 0.30.0)"
    exit 1
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  git-tfs Release Script" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Tag: v$Version" -ForegroundColor Yellow
Write-Host "Dry Run: $DryRun" -ForegroundColor Yellow
Write-Host ""

# Check if working directory is clean
$gitStatus = git status --porcelain
if ($gitStatus -and -not $DryRun) {
    Write-Host "Warning: Working directory is not clean:" -ForegroundColor Red
    git status --short
    Write-Host ""
    $response = Read-Host "Continue anyway? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Release cancelled." -ForegroundColor Red
        exit 1
    }
}

# Create tag
$tagName = "v$Version"
$commitMessage = if ($Message) { $Message } else { "Release $Version" }

Write-Host "Creating tag: $tagName" -ForegroundColor Green
Write-Host "Message: $commitMessage" -ForegroundColor Green

if (-not $DryRun) {
    # Create annotated tag
    git tag -a $tagName -m $commitMessage

    if (-not $SkipPush) {
        Write-Host ""
        Write-Host "Pushing tag to origin..." -ForegroundColor Yellow

        $pushResult = git push origin $tagName
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "===============================================" -ForegroundColor Green
            Write-Host "  SUCCESS!" -ForegroundColor Green
            Write-Host "===============================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Tag pushed successfully!" -ForegroundColor Green
            Write-Host "GitHub Actions will now build and release." -ForegroundColor Green
            Write-Host ""
            Write-Host "Track progress at:" -ForegroundColor Cyan
            Write-Host "  https://github.com/$((git remote get-url origin) -replace '.git$', '')/actions" -ForegroundColor White
            Write-Host ""
            Write-Host "Once complete, the release will be available at:" -ForegroundColor Cyan
            Write-Host "  https://github.com/$((git remote get-url origin) -replace '.git$', '')/releases/tag/$tagName" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "Failed to push tag. You can push manually with:" -ForegroundColor Red
            Write-Host "  git push origin $tagName" -ForegroundColor White
            exit 1
        }
    } else {
        Write-Host ""
        Write-Host "Tag created locally. Push with:" -ForegroundColor Yellow
        Write-Host "  git push origin $tagName" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "[DRY RUN] Would create tag: $tagName" -ForegroundColor Yellow
    Write-Host "[DRY RUN] Would push tag to origin" -ForegroundColor Yellow
}

Write-Host ""
