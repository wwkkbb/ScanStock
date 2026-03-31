# APK Build Guide

## Purpose
This file records the exact workflow, paths, commands, and caveats needed for this project.
After reading this guide, an AI or human should be able to:
- modify the web app
- sync the web assets used by Cordova
- rebuild the Android APK
- understand which file is the source of truth
- know the SDK/JDK/Gradle paths used on this machine
- diagnose the known build issues that already occurred in this project

## Source of truth
Only edit these source files directly unless there is a specific reason not to:
- `index.html`
- `pic.png`

Do not treat `apk-wrapper/www/index.html` as the primary editable file.
That file is a generated/synced copy used by the Cordova wrapper.

## Sync rule
The Cordova APK uses files under:
- `apk-wrapper/www/`

The root web assets are synced into that folder by:
- `scripts/sync-apk-www.ps1`

Current sync scope:
- `index.html`
- `pic.png`

Manual sync command from project root:
```powershell
npm run sync:apk-www
```

## Main build command
Preferred command from project root:
```powershell
npm run build:android
```

This now calls:
- `scripts/build-android.ps1`

That script does all of the following automatically:
1. syncs root assets into `apk-wrapper/www`
2. sets Android SDK / Java / Gradle environment variables
3. copies the local `gradle-7.6-all.zip` into the Gradle wrapper cache
4. runs Cordova Android build with the correct build-tools override
5. verifies the output APK exists

## Important local paths
Project root:
- `D:\SoftwareData\Project\PythonProject\PythonProject1`

Android SDK:
- `D:\Software\Android-Studio-SDK`

Java JDK:
- `D:\Study\Java\jdks\corretto-17.0.17`

Local Gradle 8.7 folder:
- `D:\SoftwareData\Project\PythonProject\PythonProject1\apk-wrapper\tools\gradle-8.7`

Local Gradle 7.6 wrapper zip used by Cordova:
- `D:\SoftwareData\Project\PythonProject\PythonProject1\gradle-7.6-all.zip`

Gradle wrapper cache target:
- `C:\Users\29918\.gradle\wrapper\dists\gradle-7.6-all\9f832ih6bniajn45pbmqhk2cw\gradle-7.6-all.zip`

Cordova executable actually used:
- `D:\SoftwareData\Project\PythonProject\PythonProject1\node_modules\.bin\cordova.cmd`

## Why Gradle 8.7 exists but the build still uses Gradle 7.6
This project contains:
- `apk-wrapper/tools/gradle-8.7`

But the actual Cordova Android platform is driven by the wrapper file:
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

That file points to:
- `https://services.gradle.org/distributions/gradle-7.6-all.zip`

So the build uses the Cordova wrapper's Gradle 7.6 distribution.
Gradle 8.7 is still useful as a local toolchain path, but it does not replace the wrapper distribution by itself.

## Why build-tools 36.1.0 is forced
Cordova's Android config expects build-tools 33.0.2 by default.
On this machine, the installed build-tools are:
- `36.1.0`
- `37.0.0`

So the build must pass this override:
- `--gradleArg=-PcdvBuildToolsVersion=36.1.0`

That override is already built into `scripts/build-android.ps1`.

## Current package scripts
Project root `package.json`:
- `npm run sync:apk-www`
- `npm run build:android`

`apk-wrapper/package.json` keeps the Cordova wrapper scripts, but the preferred top-level build entry is the root script above.

## Output APK path
Successful debug APK output:
- `apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk`

Metadata file:
- `apk-wrapper/platforms/android/app/build/outputs/apk/debug/output-metadata.json`

## Recommended workflow for future changes
1. Edit the source file(s) in the project root, usually `index.html`.
2. If needed, run a syntax check or local validation.
3. Run `npm run build:android` from the project root.
4. Install the rebuilt APK from `apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk`.
5. Verify the behavior on device.

## Known problems and fixes
### Problem: wrong Cordova path
Wrong path that failed before:
- `apk-wrapper\node_modules\.bin\cordova.cmd`

Correct path:
- `node_modules\.bin\cordova.cmd`

### Problem: Gradle wrapper tries to download online and times out
Cause:
- wrapper uses `gradle-7.6-all.zip`
- network may timeout or be blocked

Fix used in this project:
- keep a local copy at `D:\SoftwareData\Project\PythonProject\PythonProject1\gradle-7.6-all.zip`
- copy it into the wrapper cache before building

### Problem: Gradle wrapper cache lock / exclusive access timeout
Symptom:
- `waiting for exclusive access to file`

Cause:
- leftover Java/Gradle process still running after interrupted builds

Fix:
- stop leftover `java` / `gradle` processes
- rerun the build script

### Problem: Cordova asks for Android build-tools 33.0.2
Cause:
- Cordova default config does not match the locally installed SDK versions

Fix:
- build with `-PcdvBuildToolsVersion=36.1.0`

### Problem: PowerShell may corrupt Gradle `-P...=36.1.0` arguments
Cause:
- in some clean/build commands, PowerShell parsing can break the literal argument or append extra characters

Fix:
- prefer the existing root command `npm run build:android`
- if a forced clean is needed, use `cmd /c` to call `gradlew.bat` with the literal argument

### Problem: source changed but APK timestamp did not update
Cause:
- Gradle may consider previous outputs reusable and skip packaging even after synced web assets changed

Fix:
1. confirm `apk-wrapper/platforms/android/app/src/main/assets/www/index.html` already contains the new content
2. run a forced Gradle clean
3. rebuild with the normal root command `npm run build:android`

## Notes for AI agents
When asked to modify and rebuild this project, prefer this sequence:
1. edit root `index.html`
2. avoid manually editing `apk-wrapper/www/index.html` unless debugging sync itself
3. run `npm run build:android`
4. if build fails, inspect the exact error before changing paths or versions
5. remember that Cordova build uses wrapper Gradle 7.6, not just `GRADLE_HOME`
6. remember the APK uses files from `apk-wrapper/www/`, which are generated by sync

## Last known working build strategy
The last known working build path is:
```powershell
npm run build:android
```

Internally, that resolves to the same environment and parameters that previously produced a valid debug APK.
