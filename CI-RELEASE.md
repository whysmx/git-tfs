# CI/CD Release Workflow

This repository uses GitHub Actions for automated building and releasing.

## Release Build Workflow

When you push a version tag (format: `vX.Y.Z`), GitHub Actions will automatically:

1. ✅ Build the project
2. ✅ Run tests
3. ✅ Create release package
4. ✅ Create a GitHub Release
5. ✅ Upload build artifacts

### Triggering a Release

#### Method 1: Using the release script (Recommended)

```powershell
# Windows PowerShell
pwsh scripts\release.ps1 -Version 0.30.0

# Or with custom message
pwsh scripts\release.ps1 -Version 0.30.0 -Message "New features and bug fixes"

# Dry run (test without actually creating tag)
pwsh scripts\release.ps1 -Version 0.30.0 -DryRun
```

#### Method 2: Manual tag creation

```bash
# Create and push tag
git tag -a v0.30.0 -m "Release version 0.30.0"
git push origin v0.30.0
```

### Tag Format

Tags must follow semantic versioning:
- `v0.30.0` ✅
- `v1.2.3` ✅
- `v2.0.0-rc1` ✅
- `0.30.0` ❌ (missing 'v' prefix)

## Build Workflow (CI)

The `build.yml` workflow runs on:
- Push to `master` or `develop` branches
- Pull requests to `master` or `develop` branches

This workflow:
- Builds the project
- Runs tests
- Uploads build artifacts

## Release Workflow

The `release.yml` workflow runs only on version tags (`v*.*.*`).

This workflow:
- Builds the project
- Runs tests
- Creates release packages
- Creates a GitHub Release with:
  - Release notes
  - Downloadable ZIP file
  - Build artifacts

## Viewing Build Status

Visit the Actions tab to see build status:
https://github.com/whysmx/git-tfs/actions

## Viewing Releases

Visit the Releases page to download builds:
https://github.com/whysmx/git-tfs/releases

## Build Artifacts

After a successful release, you'll get:
- `GitTfs-X.Y.Z.zip` - Complete distribution package
- Individual build artifacts from each project

## Requirements

To create releases, you need:
- Push access to the repository
- No special tokens needed (GitHub Actions uses `GITHUB_TOKEN`)

## Troubleshooting

### Build fails
1. Check the Actions tab for detailed logs
2. Ensure all tests pass locally before tagging
3. Check that the build script works: `cd src && .\build.ps1 -Target Build`

### Release not created
1. Ensure tag follows format `vX.Y.Z`
2. Check that push was successful
3. Verify the workflow has permission to create releases

### Can't push tag
1. Ensure you have push access to the repository
2. Check your git credentials
3. Verify remote URL is correct: `git remote -v`

## Local Development

To build locally for testing:

```powershell
# Windows
cd src
.\build.ps1 -Target Build -Configuration Release
```

## Workflow Files

- `.github/workflows/build.yml` - Continuous Integration
- `.github/workflows/release.yml` - Release Automation
- `scripts/release.ps1` - Release helper script
