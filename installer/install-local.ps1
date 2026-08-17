# =============================================================================
#  install-local.ps1 -- run install.ps1 against THIS checkout, nothing fetched.
#
#  install.ps1 normally clones the project into a Docker volume with git. When
#  you already have a checkout on disk -- this one -- that is unnecessary and
#  slower. This script points install.ps1 at the repository this file lives in
#  (via $env:M2_REPO_DIR), which makes Copy-ProjectIntoVolume copy the files
#  straight out of this folder instead of running "git clone" at all.
#
#  This does NOT skip fetching the original r40250 server-file package, the
#  game data or the SQL dumps -- those are never part of this repository and
#  are not ours to bundle, so linux-port/fetch-sources.sh still downloads them
#  (or reads them from -ReferenceDir / -Archive / $env:M2_SRC_* if you give
#  one). Only the "clone the project itself" step is skipped.
#
#  Usage: exactly like install.ps1 -- same options, same environment
#  variables -- run from anywhere:
#
#      installer\install-local.ps1
#      installer\install-local.ps1 -Yes
#      installer\install-local.ps1 -DryRun
# =============================================================================

$ErrorActionPreference = 'Stop'

$repoRoot      = Split-Path -Parent $PSScriptRoot
$installScript = Join-Path $PSScriptRoot 'install.ps1'

if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'linux-port\fetch-sources.sh'))) {
    throw "This does not look like a checkout of the project -- '$repoRoot' has no linux-port\fetch-sources.sh next to it."
}
if (-not (Test-Path -LiteralPath $installScript)) {
    throw "install.ps1 was not found next to this script."
}

# Read by install.ps1 itself (see `$script:RepoDir` near its top). Setting it
# here, rather than passing -RepoDir, means an explicit -RepoDir on the command
# line still wins if you ever want to point at a different checkout.
$env:M2_REPO_DIR = $repoRoot

& $installScript @args
