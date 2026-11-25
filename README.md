# self-memo-mobile(随手备忘)

只装在自己 iPhone 上的原生备忘录 App。SwiftUI + SwiftData,纯本地存储,无网络、无三方依赖。

| 项 | 内容 |
|---|---|
| 工程方式 | XcodeGen(`project.yml`,CI 上生成 `MouseMemo.xcodeproj`) |
| 最低系统 | iOS 17.0(实机 iOS 27.2 直接可跑) |
| 数据 | SwiftData 本地库,存 App 沙盒,只有卸载 App 才会丢 |
| 构建 | GitHub Actions 免签名出 ipa → Windows 上侧载安装 |

## 为什么这么绕?

iOS 原生 App 的编译签名工具 Xcode 只在 macOS 上有。本项目代码在任何机器上都能写,
但"出 ipa"这一步放在 GitHub 的免费 macOS 云机器(GitHub Actions)上完成,
最后回到 Windows 用侧载工具把 ipa 签上你自己的 Apple ID 装进手机。

## 步骤一:推到 GitHub,自动出 ipa

1. 在 github.com 新建一个空仓库,名字建议 `self-memo-mobile`。
   public 仓库 Actions 完全免费;private 也有每月免费 macOS 分钟数,个人构建绰绰有余。
2. 本地执行(把 `<你的用户名>` 换掉):

```bash
cd /d/mouse/self-memo-mobile
git remote add origin https://github.com/<你的用户名>/self-memo-mobile.git
git push -u origin main
```

3. push 后自动触发 `.github/workflows/build.yml`:
   装 XcodeGen → 生成工程 → xcodebuild 免签名编译 → 打包 ipa → 上传 artifact。
4. 打开仓库页 **Actions** 标签 → 点最新一次运行 → 页面底部 **Artifacts** 下载
   `MouseMemo-unsigned-ipa`,解压得到 `MouseMemo-unsigned.ipa`。
   以后每次改完代码 push 都会自动出一份新 ipa;也可在 Actions 页手动 Run workflow。

## 步骤二:Windows 上侧载安装(Sideloadly)

1. iPhone 用**数据线**连电脑;电脑装好 Apple 设备驱动
   (安装 [apple.com 官网版 iTunes](https://www.apple.com/itunes/) 即可,Microsoft Store 版驱动偶尔不全)。
2. 下载安装 [Sideloadly](https://sideloadly.io)。
3. 打开 Sideloadly:把 `MouseMemo-unsigned.ipa` 拖进左侧框,**Apple ID** 栏填你的 Apple ID,点 Start。
   签名和安装走网络,几分钟完成。
4. 首次安装要在手机上信任开发者:设置 → 通用 → VPN与设备管理 → 点你的 Apple ID(开发者证书)→ 信任。
5. 桌面出现「随手备忘」。

## 免费账号的三条规则(重要)

| 规则 | 说明 |
|---|---|
| 7 天掉签 | App 每 7 天过期,打开即闪退。**此时不要卸载!** 连电脑重跑一次 Sideloadly 即可复活,数据不丢 |
| 最多 3 个 | 一个免费 Apple ID 同时最多侧载 3 个 App |
| 无高级权限 | 推送、iCloud 同步等免费用不了;本 App 全本地,不受影响 |

> 想省掉手动续签:
> - 手机和电脑常在同一 Wi-Fi → 装一体化的 [AltStore](https://altstore.io)(Windows 端 AltServer),由它侧载 ipa 后会自动续签;
> - 或者 ¥688/年 个人开发者账号,Ad-hoc 签名一年有效,还带 TestFlight。

## 二次开发

- 界面和逻辑都在 `Sources/` 下四个 Swift 文件里,直接改;
- `project.yml` 里改 App 显示名、bundle id(只在撞名时才需要);
- 改完 `git push` → Actions 出新 ipa → 同 bundle id 覆盖安装,**数据保留**;
- ⚠️ 换另一个 Apple ID 签名再覆盖安装会清数据;需要备份/导出功能的话后续可以加。

## 目录结构

```
self-memo-mobile/
├── project.yml                    # XcodeGen 工程定义
├── Sources/
│   ├── MouseMemoApp.swift         # 入口 + SwiftData 容器
│   ├── Memo.swift                 # 数据模型
│   ├── MemoListView.swift         # 列表 + 搜索 + 删除
│   └── MemoEditView.swift         # 编辑页(自动保存)
├── Resources/Assets.xcassets/     # App 图标
└── .github/workflows/build.yml    # 云端构建流水线
```
