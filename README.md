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

## 步骤二:Windows 上侧载安装(AltStore,自动续签)

1. 电脑装 Apple 设备驱动:安装 [apple.com 官网版 iTunes](https://www.apple.com/itunes/) 和
   同页的 iCloud(Microsoft Store 版驱动偶尔不全,已装官网 iTunes 就够了)。
2. 下载安装 [AltServer for Windows](https://altstore.io),装完常驻系统托盘(开机自启,保持运行)。
3. iPhone 数据线连电脑,解锁并点"信任此电脑";托盘 AltServer 图标 → Install AltStore → 选你的手机,
   按提示输入 Apple ID。开了双重认证的账号要填
   [App 专用密码](https://appleid.apple.com)(登录后 登录与安全 → App 专用密码 生成一个)。
4. 手机上出现 AltStore 后,先信任开发者:设置 → 通用 → VPN与设备管理 → 点你的 Apple ID → 信任。
5. 侧载备忘录:托盘 AltServer 图标 → **Sideload .ipa** → 选本地 `build/MouseMemo-unsigned.ipa`。
   (或把 ipa 传到手机的"文件"里,在 AltStore 的 My Apps → + 里选它,效果相同。)
6. 桌面出现「随手备忘」。之后只要手机和电脑在同一 Wi-Fi,AltStore 会自动续签,7 天掉签基本无感。

> 掉签了(点开闪退)也不怕:连上电脑让 AltStore/AltServer 刷新一次即可复活,**不要卸载**,数据不丢。
> 备选方案:[Sideloadly](https://sideloadly.io) 手动侧载,不用装 AltStore,但没有自动续签。

## 免费账号的三条规则(重要)

| 规则 | 说明 |
|---|---|
| 7 天掉签 | App 每 7 天过期,打开即闪退。**此时不要卸载!** 连电脑重跑一次 Sideloadly 即可复活,数据不丢 |
| 最多 3 个 | 一个免费 Apple ID 同时最多侧载 3 个 App |
| 无高级权限 | 推送、iCloud 同步等免费用不了;本 App 全本地,不受影响 |

> 想彻底不操心续签:¥688/年 个人开发者账号,Ad-hoc 签名一年有效,还带 TestFlight。

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
