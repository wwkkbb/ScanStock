# GitHub 上传建议

更新时间：2026-04-01

## 1. 建议提交到 Git 的内容
这些内容建议纳入 Git：
- `index.html`
- `pic.png`
- `package.json`
- `package-lock.json`
- `scripts/`
- `APK_BUILD_GUIDE.md`
- `SETUP_FROM_GITHUB.md`
- `index.html 分析报告.md`
- `prompt_simple.txt`
- `prompt_strict.txt`
- `apk-wrapper/config.xml`
- `apk-wrapper/package.json`
- `apk-wrapper/www/`

如果你要保留当前 APK 的导出能力，也建议提交这些 Android 原生文件：
- `apk-wrapper/platforms/android/app/src/main/java/com/cashier/app/MainActivity.java`
- `apk-wrapper/platforms/android/app/src/main/AndroidManifest.xml`
- `apk-wrapper/platforms/android/app/src/main/res/xml/file_paths.xml`
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

原因是当前项目里有手工原生改动，尤其是导出桥逻辑直接放在 `MainActivity.java` 中。

## 2. 不建议提交到 Git 的内容
这些通常不建议上传：
- `node_modules/`
- `apk-wrapper/node_modules/`
- `.npm-cache/`
- `.idea/`
- `index_temp.html`
- `gradle-7.6-all.zip`
- `apk-wrapper/tools/`
- `apk-wrapper/platforms/android/app/build/`
- `apk-wrapper/platforms/android/CordovaLib/build/`
- `*.apk`
- `*.aab`
- 其他本地缓存、日志、临时文件

## 3. 关于 `apk-wrapper/platforms/`
正常 Cordova 项目通常不提交整个 `platforms/`。

但你这个项目目前存在一个现实情况：
- Android 原生层已经有手工修改
- 这些修改目前直接落在 `platforms/android/...`

当前更实用的做法是：
- 不必提交整个 `platforms/android`
- 但要提交真正改过、且会影响 APK 功能的关键原生文件

当前尤其重要的是：
- `MainActivity.java`

因为手动导出和自动导出都依赖它。

## 4. 当前推荐的 Git 策略
建议提交：
- 主源码
- 构建脚本
- 文档
- prompt
- `apk-wrapper/www`
- `apk-wrapper/config.xml`
- 关键 Android 原生改动文件

建议忽略：
- 依赖
- 缓存
- 构建产物
- IDE 配置
- 本地临时文件

## 5. 推送前检查
推送到 GitHub 前建议先检查：
1. `git status`
2. 确认没有把 `node_modules`、`.npm-cache`、`.idea`、`*.apk` 提交进去
3. 确认 `index.html`、脚本、文档、prompt 已纳入
4. 确认 `MainActivity.java` 等关键原生文件已纳入
5. 确认没有把本机绝对路径误写进新的业务逻辑里
