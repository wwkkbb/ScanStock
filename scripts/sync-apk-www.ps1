$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = $projectRoot
$targetRoot = Join-Path $projectRoot 'apk-wrapper\www'

$filesToSync = @(
    'index.html',
    'pic.png'
)

foreach ($relativePath in $filesToSync) {
    $sourcePath = Join-Path $sourceRoot $relativePath
    $targetPath = Join-Path $targetRoot $relativePath

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Source file not found: $sourcePath"
    }

    $targetDir = Split-Path -Parent $targetPath
    if (-not (Test-Path -LiteralPath $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    Write-Output "Synced $relativePath"
}
