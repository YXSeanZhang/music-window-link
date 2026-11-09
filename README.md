# Music Window Link

一个 Windows 小工具，让 Microsoft Store 版 Apple Music 与 Lyricify Fusion 随窗口开关联动。

## 使用方法

1. 通过 Microsoft Store 安装 Apple Music 和 Lyricify Fusion。
2. 解压 ZIP 到一个固定文件夹，保留两个脚本在同一目录。
3. 双击 `Setup-Link.cmd`，按 **1** 启用。以后每次登录当前 Windows 账户时，脚本自动运行。无需管理员权限。
4. 停用时再次打开 `Setup-Link.cmd`，按 **2**。如需移动或删除文件，请先停用。

打开 Apple Music 窗口时，工具会启动尚未运行的 Fusion。关闭 Apple Music 窗口约 4–6 秒后，工具会尝试关闭本轮由它启动的 Fusion，必要时结束其进程。最小化 Apple Music 时会保留 Fusion。如果 Fusion 已在运行，工具会保留该实例。

首次验证时，先从系统托盘退出 Fusion，再打开 Apple Music，最后关闭 Apple Music 窗口并等待数秒。

## 实现与适用范围

工具使用 Windows PowerShell、Windows 应用标识和主窗口检测。安装脚本在当前用户的启动文件夹创建快捷方式，PowerShell 的执行策略参数只用于该次进程。联动脚本仅在本机运行，无联网依赖。当前版本适配两个应用的 Microsoft Store 版。

## 第三方应用与权利

这是独立的兼容性工具，与 Apple 或 Lyricify 的开发者没有隶属或背书关系。第三方名称仅用于标明兼容的应用，各自的权利归相关权利人。此项目仅分发联动脚本和说明，两个应用请通过官方渠道获取。

- [Apple Music for Windows](https://apps.microsoft.com/detail/9pfhdd62mxs1)
- [Lyricify Fusion 官方文档](https://docs.lyricify.app/en/lyricify-fusion/)

本项目当前未授予额外的开源许可。
