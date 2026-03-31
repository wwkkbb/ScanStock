# 从 GitHub 下载后如何快速配置环境

更新时间：2026-03-31

## 1. 适用场景

这份文档用于以下场景：

- 你从 GitHub 重新下载了这个项目
- 你换了一台 Windows 电脑
- 你要让新的 Codex / AI 快速恢复这个项目的构建环境
- 你要重新具备修改网页并打包 Android APK 的能力

当前文档默认环境是：
- Windows
- PowerShell
- Android APK 打包
- Cordova Android

## 2. 下载项目后先看哪些文件

建议先阅读：

- `APK_BUILD_GUIDE.md`
- `index.html 分析报告.md`
- `package.json`
- `scripts/build-android.ps1`
- `scripts/sync-apk-www.ps1`
- `apk-wrapper/config.xml`
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

如果是让 Codex 接手，再额外给它：

- `prompt_simple.txt`
或
- `prompt_strict.txt`

## 3. 需要安装的软件

至少准备这些：

### 3.1 Node.js

建议安装 LTS 版本。

安装后确认：

```powershell
node -v
npm -v
```

### 3.2 Java JDK 17

当前项目使用的是 JDK 17。

建议安装后确认：

```powershell
java -version
```

### 3.3 Android Studio 或 Android SDK

至少需要：

- Android SDK
- platform-tools
- build-tools
- command-line tools

建议准备：

- Android SDK Build-Tools 36.1.0
- Android SDK Platform 34

### 3.4 Git

用于拉取项目和提交到 GitHub。

确认：

```powershell
git --version
```

## 4. 首次进入项目后要做什么

项目根目录：

```powershell
cd D:\SoftwareData\Project\PythonProject\PythonProject1
```

先安装根目录依赖：

```powershell
npm install
```

如果 `apk-wrapper` 下还没有依赖，再安装一次：

```powershell
cd apk-wrapper
npm install
cd ..
```

## 5. 你必须知道的项目结构

### 5.1 主源码

真正应该优先修改的是：

- `index.html`

### 5.2 APK 打包副本

Cordova 真正打包使用的是：

- `apk-wrapper/www/index.html`

它不是主源码，而是同步副本。

### 5.3 自动同步脚本

同步根目录资源到 APK 副本的脚本是：

- `scripts/sync-apk-www.ps1`

当前默认同步：

- `index.html`
- `pic.png`

如果以后新增根目录资源需要打进 APK，要更新这个脚本。

## 6. 当前项目默认构建方式

推荐直接在项目根目录执行：

```powershell
npm run build:android
```

这个命令会自动：

1. 同步根目录网页资源到 `apk-wrapper/www`
2. 设置 Android SDK / Java / Gradle 环境变量
3. 复用本地 `gradle-7.6-all.zip`
4. 调用 Cordova Android 打包
5. 输出 debug APK

APK 产物路径固定查看：

```text
apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

## 7. 下载后最容易缺的内容

如果你是从 GitHub 重新拉项目，最常见缺的是这几类：

- `node_modules/`
- `apk-wrapper/node_modules/`
- `.npm-cache/`
- `apk-wrapper/tools/`
- `gradle-7.6-all.zip`

这些通常不会提交到 Git。

所以你要分别处理。

## 8. 新机器上推荐怎么补齐环境

### 8.1 安装 npm 依赖

在项目根目录：

```powershell
npm install
```

在 `apk-wrapper` 目录：

```powershell
cd apk-wrapper
npm install
cd ..
```

### 8.2 如果 `platforms/android` 不完整

如果 GitHub 版本没有完整 Android 平台目录，或者你后续重建了 Cordova 平台，可以在根目录先确保有 Cordova 依赖，然后执行类似：

```powershell
node_modules\.bin\cordova.cmd platform add android
```

但要注意：

当前项目有少量手工改过的 Android 原生文件，例如：
- `SystemWebChromeClient.java`
- `AndroidManifest.xml`
- `file_paths.xml`

如果你重建了平台目录，要确认这些改动是否还保留。

## 9. 需要按本机修改的路径

当前 `scripts/build-android.ps1` 写了本机绝对路径。

如果你换电脑，最需要改的是这里：

- `ANDROID_HOME`
- `ANDROID_SDK_ROOT`
- `JAVA_HOME`

当前脚本里示例路径是：

```powershell
$env:ANDROID_HOME = 'D:\Software\Android-Studio-SDK'
$env:ANDROID_SDK_ROOT = 'D:\Software\Android-Studio-SDK'
$env:JAVA_HOME = 'D:\Study\Java\jdks\corretto-17.0.17'
```

新电脑上如果路径不同，必须改成你自己的实际路径。

## 10. Gradle 相关的关键事实

### 10.1 为什么本地有 Gradle 8.7，但打包还会走 7.6

因为 Cordova Android 实际读取的是：

- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

这里指定的是：

- `gradle-7.6-all.zip`

所以构建时真正使用的是 wrapper 指定的 Gradle 7.6。

### 10.2 为什么需要 `gradle-7.6-all.zip`

如果没有这个 zip，Gradle wrapper 可能会联网下载。

网络不稳定时会失败，所以当前项目偏向使用本地缓存 zip。

如果你从 GitHub 下载后没有这个文件，有两种做法：

1. 手动下载 `gradle-7.6-all.zip` 放到项目根目录
2. 允许 Gradle wrapper 首次联网下载

## 11. Android build-tools 的要求

当前项目构建时需要显式使用：

- `36.1.0`

原因是 Cordova 默认可能去找旧版本 `33.0.2`，而你的机器通常装的是更新版本。

这部分已经写在：

- `scripts/build-android.ps1`

一般不要手动改掉。

## 12. 快速验证环境是否正常

可以按这个顺序测试：

### 12.1 先同步网页资源

```powershell
npm run sync:apk-www
```

### 12.2 再正式打包

```powershell
npm run build:android
```

### 12.3 检查 APK 是否产出

检查：

```text
apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

## 13. 常见问题

### 13.1 `cordova.cmd` 路径错误

错误写法：

```text
apk-wrapper\node_modules\.bin\cordova.cmd
```

当前项目应使用：

```text
node_modules\.bin\cordova.cmd
```

### 13.2 PowerShell 里 Gradle 参数传坏

如果你手动执行 `gradlew.bat clean` 一类命令，`-PcdvBuildToolsVersion=36.1.0` 可能在 PowerShell 下解析异常。

这时更稳的是：

```powershell
cmd /c gradlew.bat ...
```

### 13.3 源码改了，但 APK 还是旧的

先检查：

- 是否已经同步到 `apk-wrapper/www/index.html`
- 是否真的重新打包
- APK 时间是否变化

必要时先 clean 再 build。

### 13.4 Gradle 被占锁

如果看到类似：

- `waiting for exclusive access to file`

通常是残留 Java / Gradle 进程没退出，需要先结束进程再重新构建。

## 14. 给未来 Codex 的最短交接方式

如果以后你要让 Codex 更快进入项目，推荐直接把下面文件一起给它：

- `APK_BUILD_GUIDE.md`
- `index.html 分析报告.md`
- `SETUP_FROM_GITHUB.md`
- `prompt_simple.txt`

如果你希望它先汇报理解再动手，就给：

- `prompt_strict.txt`

## 15. 一句话总结

从 GitHub 下载后，最快恢复这个项目的方法是：

1. 安装 Node.js、JDK 17、Android SDK
2. 运行 `npm install`
3. 按机器实际情况修改 `scripts/build-android.ps1` 里的 SDK/JDK 路径
4. 准备好 `gradle-7.6-all.zip` 或允许首次联网下载
5. 在项目根目录运行 `npm run build:android`
