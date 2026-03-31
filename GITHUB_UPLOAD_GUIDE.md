# GitHub 上传建议

更新时间：2026-03-31

## 1. 建议提交到 Git 的内容

这些内容建议纳入 Git，原因是它们属于源码、文档或构建流程本身：

- `index.html`
- `pic.png`
- `package.json`
- `package-lock.json`
- `scripts/`
- `APK_BUILD_GUIDE.md`
- `index.html 分析报告.md`
- `prompt_simple.txt`
- `prompt_strict.txt`
- `apk-wrapper/config.xml`
- `apk-wrapper/package.json`
- `apk-wrapper/www/`

如果你希望保留当前 Android 原生拍照兼容改动，也建议纳入这些原生文件：
- `apk-wrapper/platforms/android/CordovaLib/src/org/apache/cordova/engine/SystemWebChromeClient.java`
- `apk-wrapper/platforms/android/app/src/main/AndroidManifest.xml`
- `apk-wrapper/platforms/android/app/src/main/res/xml/file_paths.xml`
- `apk-wrapper/platforms/android/gradle/wrapper/gradle-wrapper.properties`

## 2. 不建议提交到 Git 的内容

这些内容通常属于依赖、缓存、构建产物或本机私有配置，不建议上传：

- `node_modules/`
- `apk-wrapper/node_modules/`
- `.npm-cache/`
- `.idea/`
- `.codex-tmp-*.js`
- `index_temp.html`
- `gradle-7.6-all.zip`
- `apk-wrapper/tools/`
- `apk-wrapper/platforms/android/app/build/`
- `apk-wrapper/platforms/android/CordovaLib/build/`
- `*.apk`
- `*.aab`
- 其他本机缓存、日志、临时文件

## 3. 关于 `apk-wrapper/platforms/` 的说明

正常的 Cordova 项目通常不提交整个 `platforms/` 目录。

但你这个项目有一个现实情况：
- Android 原生层已经做过手工修改
- 这些修改目前直接落在 `platforms/android/...` 下面

所以现在有两种做法：

### 做法 A：先求稳，提交少量必要原生文件

适合当前项目。

建议：
- 不提交整个 `platforms/android`
- 只提交已经手工改过、确实需要保留的原生文件

这样能兼顾：
- 仓库不至于太大
- 关键原生改动不会丢

### 做法 B：后续再整理成可重建的原生补丁方案

更规范，但现在不是必须。

可以后续再做：
- 把原生改动迁移到插件、hook、patch 或独立脚本
- 让 `platform add android` 后仍能自动恢复这些修改

## 4. 当前最推荐的 Git 策略

当前项目建议：

提交：
- 主源码
- 构建脚本
- 文档
- 两个 prompt
- `apk-wrapper/www`
- `apk-wrapper/config.xml`
- 少量关键 Android 原生改动文件

忽略：
- 依赖
- 缓存
- 构建产物
- IDE 配置
- 本地临时文件

## 5. 推送前检查

推到 GitHub 前建议先检查：

1. `git status`
2. 确认没有把 `node_modules`、`.npm-cache`、`.idea`、`*.apk` 提交进去
3. 确认 `index.html`、脚本、文档、prompt 已纳入
4. 确认原生拍照兼容相关文件是否已纳入
5. 确认没有误把本机绝对路径写进代码逻辑里
