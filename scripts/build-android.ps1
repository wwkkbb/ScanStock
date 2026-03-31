$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$apkWrapperRoot = Join-Path $projectRoot 'apk-wrapper'
$gradleCacheDir = 'C:\Users\29918\.gradle\wrapper\dists\gradle-7.6-all\9f832ih6bniajn45pbmqhk2cw'
$localGradleZip = Join-Path $projectRoot 'gradle-7.6-all.zip'
$cachedGradleZip = Join-Path $gradleCacheDir 'gradle-7.6-all.zip'

$env:ANDROID_HOME = 'D:\Software\Android-Studio-SDK'
$env:ANDROID_SDK_ROOT = 'D:\Software\Android-Studio-SDK'
$env:JAVA_HOME = 'D:\Study\Java\jdks\corretto-17.0.17'
$env:GRADLE_HOME = Join-Path $apkWrapperRoot 'tools\gradle-8.7'
$env:npm_config_cache = Join-Path $projectRoot '.npm-cache'
$env:Path = "$($env:GRADLE_HOME)\bin;D:\Software\Android-Studio-SDK\platform-tools;D:\Study\Java\jdks\corretto-17.0.17\bin;$($env:Path)"

Write-Output 'Syncing root web assets to apk-wrapper/www ...'
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $projectRoot 'scripts\sync-apk-www.ps1')
if ($LASTEXITCODE -ne 0) {
    throw 'Asset sync failed.'
}

if (-not (Test-Path -LiteralPath $localGradleZip)) {
    throw "Missing local Gradle wrapper zip: $localGradleZip"
}

New-Item -ItemType Directory -Path $gradleCacheDir -Force | Out-Null
Remove-Item -LiteralPath (Join-Path $gradleCacheDir 'gradle-7.6-all.zip.part') -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath $localGradleZip -Destination $cachedGradleZip -Force
Write-Output 'Prepared local Gradle 7.6 wrapper zip cache.'

Push-Location $apkWrapperRoot
try {
    & (Join-Path $projectRoot 'node_modules\.bin\cordova.cmd') build android -- --gradleArg=-PcdvBuildToolsVersion=36.1.0 --no-telemetry
    if ($LASTEXITCODE -ne 0) {
        throw "Cordova build failed with exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

$apkPath = Join-Path $apkWrapperRoot 'platforms\android\app\build\outputs\apk\debug\app-debug.apk'
if (-not (Test-Path -LiteralPath $apkPath)) {
    throw "APK not found after build: $apkPath"
}

$apk = Get-Item -LiteralPath $apkPath
Write-Output "APK ready: $($apk.FullName)"
Write-Output "LastWriteTime: $($apk.LastWriteTime)"
Write-Output "Size: $($apk.Length) bytes"
