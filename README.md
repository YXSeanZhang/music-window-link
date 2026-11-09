# WindowLink for Apple Music and Lyricify Fusion

一个 Windows 小工具，让 Microsoft Store 版 Apple Music 与 Lyricify Fusion 随窗口开关联动。

## 使用方法

1. 通过 Microsoft Store 安装 Apple Music 和 Lyricify Fusion。
2. 解压 ZIP 到一个固定文件夹，保留三个脚本在同一目录。
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

从 v1.0.0 升级时，先用旧版 Setup-Link.cmd 按 2 停用，等待数秒，再用新版按 1 启用。新版登录时静默运行。


## 性能实测

在一台有 32 个逻辑处理器的 Windows 电脑上，Apple Music 未运行时采样 30 秒。联动后台进程消耗约 0.156 CPU 秒，折合整机平均 CPU 占用约 0.016%。采样结束时物理内存工作集约 100 MiB。脚本约每 2 秒检查一次进程和窗口，其余时间休眠。此结果只涵盖该电脑上的空闲常驻状态。

## 停用和卸载

1. 在当前安装目录双击 Setup-Link.cmd，按 2。它会删除当前 Windows 用户的登录启动快捷方式。
2. 等待数秒，让后台监视进程退出。如果 Apple Music 或 Lyricify Fusion 仍打开，可按平时的方式关闭。
3. 删除安装目录中的 Setup-Link.cmd、AppleMusic-Lyricify.ps1、Start-Link.vbs（v1.0.1 起）和 README.md。若该目录只存放本工具，也可删除整个目录。

如果脚本已经移走或删除，按 Win + R，输入 shell:startup 并回车，在打开的文件夹中删除名为 Apple Music - Lyricify Fusion 的快捷方式。若监视进程仍在运行，等待数秒即可。卸载只移除联动工具，两个应用及其设置仍可正常使用。
