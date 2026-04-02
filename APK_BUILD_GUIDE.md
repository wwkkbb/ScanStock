# APK Build Guide

## Purpose
This guide records the current build workflow, storage behavior, and Android-specific caveats for this project.

After reading it, a human or AI should be able to:
- edit the real source files
- sync web assets into the Cordova wrapper
- rebuild the Android APK
- understand backup vs export behavior
- know which Android native file was manually modified

## Source Of Truth
Edit these files directly unless there is a specific reason not to:
- `index.html`
- `pic.png`

Do not treat `apk-wrapper/www/index.html` as the primary editable file.
That file is only the synced copy used by the Cordova wrapper.

## Sync Rule
The APK uses files under:
- `apk-wrapper/www/`

The sync script is:
- `scripts/sync-apk-www.ps1`

Current sync scope:
- `index.html`
- `pic.png`

Manual sync command:
```powershell
npm run sync:apk-www
```

## Main Build Command
Preferred command from project root:
```powershell
npm run build:android
```

That command runs:
- `scripts/build-android.ps1`

The script does all of the following:
1. syncs root assets into `apk-wrapper/www`
2. sets Android SDK, Java, Gradle, and npm cache environment variables
3. copies the local `gradle-7.6-all.zip` into the Gradle wrapper cache
4. builds the Cordova Android app with the required build-tools override
5. verifies the APK output exists

## Important Paths
Project root:
- `D:\SoftwareData\Project\PythonProject\PythonProject1`

Android SDK:
- `D:\Software\Android-Studio-SDK`

Java JDK:
- `D:\Study\Java\jdks\corretto-17.0.17`

Local Gradle 8.7:
- `D:\SoftwareData\Project\PythonProject\PythonProject1\apk-wrapper\tools\gradle-8.7`

Local Gradle 7.6 wrapper zip:
- `D:\SoftwareData\Project\PythonProject\PythonProject1\gradle-7.6-all.zip`

Gradle wrapper cache target:
- `C:\Users\29918\.gradle\wrapper\dists\gradle-7.6-all\9f832ih6bniajn45pbmqhk2cw\gradle-7.6-all.zip`

Cordova executable actually used:
- `D:\SoftwareData\Project\PythonProject\PythonProject1\node_modules\.bin\cordova.cmd`

APK output:
- `apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk`

## Why Gradle 7.6 Is Still Used
The project contains:
- `apk-wrapper/tools/gradle-8.7`

But Cordova Android actually uses the wrapper defined in:
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

That wrapper points to:
- `gradle-7.6-all.zip`

So the build still runs on Gradle 7.6.

## Why Build-Tools 36.1.0 Is Forced
Cordova Android expects an older default build-tools version.
On this machine, the installed versions are newer, so the build must pass:
- `--gradleArg=-PcdvBuildToolsVersion=36.1.0`

That override is already built into:
- `scripts/build-android.ps1`

## Current Data Behavior
This project now clearly separates backup and export.

Application-internal backup:
- stored in IndexedDB
- used for manual backup and emergency backup
- intended for recovery from bad operations

Manual export in APK:
- opens Android system "Create document" UI
- user chooses the save location
- intended for long-term external retention or migration

Automatic export in APK:
- runs only when both conditions are true:
  1. at least 15 days passed since the last automatic export
  2. product or history data changed
- writes a JSON file into Android Downloads under:
  - `Downloads/cashier-backups/`

Browser mode:
- export still downloads a JSON file through the browser
- backup still stays in IndexedDB

## Android Native Customization
The APK export behavior is not only web-side now.

Important manual Android change:
- `apk-wrapper/platforms/android/app/src/main/java/com/cashier/app/MainActivity.java`

That file now contains a native bridge used by the web app to:
- open Android's system save dialog for manual export
- save automatic exports into Downloads via Android native APIs

This matters because:
- if you recreate `platforms/android`, this change will be lost
- after platform recreation, you must restore or reapply this file change

## Current Package Scripts
Project root `package.json`:
- `npm run sync:apk-www`
- `npm run build:android`

`apk-wrapper/package.json` still exists for the wrapper, but the top-level root commands remain the preferred entry point.

## Recommended Workflow
1. Edit root `index.html`.
2. If needed, do a syntax or logic check.
3. Run `npm run build:android`.
4. Install the rebuilt APK.
5. Verify backup/export behavior on device.

## Known Problems And Fixes
### Wrong Cordova path
Wrong:
- `apk-wrapper\node_modules\.bin\cordova.cmd`

Correct:
- `node_modules\.bin\cordova.cmd`

### Gradle wrapper tries to download online and times out
Fix:
- keep `gradle-7.6-all.zip` locally
- let `scripts/build-android.ps1` copy it into wrapper cache before build

### Gradle cache lock or exclusive access timeout
Symptom:
- `waiting for exclusive access to file`

Fix:
- stop leftover Java or Gradle processes
- rerun the build script

### Build-tools version mismatch
Fix:
- keep using `-PcdvBuildToolsVersion=36.1.0`
- do not remove it from the build script

### Source changed but APK did not reflect the change
Fix:
1. confirm `apk-wrapper/www/index.html` was synced
2. rebuild with `npm run build:android`
3. confirm the new APK timestamp changed

### Manual export fails because native bridge timing is wrong
Current fix:
- the web layer waits for the native exporter bridge instead of depending only on `deviceready`
- the Android side opens the system save dialog on the UI thread

## Notes For AI Agents
When modifying this project:
1. edit root `index.html`
2. avoid editing `apk-wrapper/www/index.html` directly unless debugging sync
3. remember backup and export are now different behaviors
4. remember manual and automatic export depend on native code in `MainActivity.java`
5. if `platforms/android` is recreated, restore the native export bridge
6. use `npm run build:android` as the preferred build path

## Last Known Working Build Strategy
```powershell
npm run build:android
```

That command produced a valid debug APK after the native export bridge changes.
