# 从 GitHub 下载后如何恢复环境

更新时间：2026-04-01

## 1. 适用场景
这份文档适用于：
- 你重新从 GitHub 拉取了项目
- 你换了一台 Windows 电脑
- 你需要让新的 AI 或人工快速恢复 APK 构建能力

当前默认环境：
- Windows
- PowerShell
- Cordova Android

## 2. 先看哪些文件
建议先看：
- `APK_BUILD_GUIDE.md`
- `index.html 分析报告.md`
- `package.json`
- `scripts/build-android.ps1`
- `scripts/sync-apk-www.ps1`
- `apk-wrapper/config.xml`
- `apk-wrapper/package.json`

如果要让 AI 接手，再额外给它：
- `prompt_simple.txt`
- 或 `prompt_strict.txt`

## 3. 需要的软件
至少准备这些：

### 3.1 Node.js
建议安装 LTS。

确认：
```powershell
node -v
npm -v
```

### 3.2 Java JDK 17
确认：
```powershell
java -version
```

### 3.3 Android SDK
至少需要：
- platform-tools
- command-line tools
- Android SDK Platform 34
- Android SDK Build-Tools 36.1.0

### 3.4 Git
确认：
```powershell
git --version
```

## 4. 首次进入项目后做什么
项目根目录：
```powershell
cd D:\SoftwareData\Project\PythonProject\PythonProject1
```

安装根目录依赖：
```powershell
npm install
```

如果 `apk-wrapper` 下也缺少依赖：
```powershell
cd apk-wrapper
npm install
cd ..
```

## 5. 你必须知道的项目结构
主源码：
- `index.html`

APK 使用的同步副本：
- `apk-wrapper/www/index.html`

同步脚本：
- `scripts/sync-apk-www.ps1`

当前同步范围：
- `index.html`
- `pic.png`

如果后续新增资源要进 APK，需要同步更新：
- `scripts/sync-apk-www.ps1`

## 6. 默认构建方式
推荐直接在项目根目录执行：
```powershell
npm run build:android
```

这个命令会自动：
1. 同步网页资源到 `apk-wrapper/www`
2. 设置 Android SDK / Java / Gradle 环境变量
3. 复用本地 `gradle-7.6-all.zip`
4. 调用 Cordova Android 构建
5. 输出 debug APK

APK 位置：
- `apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk`

## 7. 当前数据行为
现在要区分“备份”和“导出”。

应用内备份：
- 手动备份
- 应急备份
- 都保存在 IndexedDB

手动导出：
- APK 内会弹出 Android 系统保存窗口
- 用户自己选择保存位置

自动导出：
- 只有在“距离上次自动导出已满 15 天”并且“数据有变化”时才触发
- 导出到 Android 下载目录：
  - `Downloads/cashier-backups/`

## 8. 重要原生文件
当前 APK 导出能力依赖这份手工修改过的 Android 原生文件：
- `apk-wrapper/platforms/android/app/src/main/java/com/cashier/app/MainActivity.java`

它负责：
- 手动导出时拉起系统保存窗口
- 自动导出时写入 Downloads

如果你重建了 `platforms/android`，这份修改会丢。
重建后必须确认它是否已经恢复。

## 9. 新机器上最容易缺的内容
常见缺失项：
- `node_modules/`
- `apk-wrapper/node_modules/`
- `.npm-cache/`
- `apk-wrapper/tools/`
- `gradle-7.6-all.zip`

这些通常不会进 Git，需要你自己补齐。

## 10. 路径相关注意事项
当前 `scripts/build-android.ps1` 写了本机绝对路径。
换机器后最可能要改的是：
- `ANDROID_HOME`
- `ANDROID_SDK_ROOT`
- `JAVA_HOME`

当前示例值：
```powershell
$env:ANDROID_HOME = 'D:\Software\Android-Studio-SDK'
$env:ANDROID_SDK_ROOT = 'D:\Software\Android-Studio-SDK'
$env:JAVA_HOME = 'D:\Study\Java\jdks\corretto-17.0.17'
```

## 11. Gradle 相关关键点
虽然项目里有：
- `apk-wrapper/tools/gradle-8.7`

但 Cordova Android 实际使用的是 wrapper 指定的：
- Gradle 7.6

所以不要只看本地 Gradle 目录，要看：
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

## 12. 快速验证环境
先同步：
```powershell
npm run sync:apk-www
```

再构建：
```powershell
npm run build:android
```

最后检查 APK：
- `apk-wrapper/platforms/android/app/build/outputs/apk/debug/app-debug.apk`

## 13. 常见问题
### `cordova.cmd` 路径错误
错误写法：
- `apk-wrapper\node_modules\.bin\cordova.cmd`

正确写法：
- `node_modules\.bin\cordova.cmd`

### Gradle wrapper 在线下载失败
解决方式：
- 准备好本地 `gradle-7.6-all.zip`
- 让现有脚本自动复制到 wrapper 缓存

### PowerShell 传递 Gradle 参数异常
如果手工执行 `gradlew.bat`，`-PcdvBuildToolsVersion=36.1.0` 可能被 PowerShell 破坏。
优先用：
- `npm run build:android`

### 重建 Android 平台后导出失效
先检查：
- `MainActivity.java` 里的原生导出桥是否还在
- 是否仍然存在手动导出和自动导出的原生逻辑

## 14. 一句话总结
恢复这个项目最快的方法是：
1. 安装 Node.js、JDK 17、Android SDK
2. 跑 `npm install`
3. 检查 `scripts/build-android.ps1` 里的本机路径
4. 确保 `gradle-7.6-all.zip` 存在
5. 运行 `npm run build:android`
