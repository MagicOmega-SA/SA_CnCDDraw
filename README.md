# SA_CnCDDraw

《心灵终结》3.3.6 的 32 位 CnC-DDraw 渲染器替换包，将客户端内置的 1.3.5.0 更新到 7.1.0.0。客户端仍使用原有的 **CnC-DDraw** 选项。[上游版本](https://github.com/FunkyFr3sh/cnc-ddraw/releases/tag/v7.1.0.0)

## 下载与使用

日常使用下载 `cnc-ddraw.dll`（无日志版）和 `cnc-ddraw.ini`。排查渲染问题时可选 `cnc-ddraw-logging.dll`，下载后改名为 `cnc-ddraw.dll`。[GitHub Release](https://github.com/MagicOmega-SA/SA_CnCDDraw/releases/latest)

1. 关闭游戏和客户端。备份 `Resources` 里的 `cnc-ddraw.dll`、`cnc-ddraw.ini`，以及游戏根目录现有的 `ddraw.dll`、`ddraw.ini` 和 `RA2MO.ini`。
2. 将新版 DLL 和 INI 放入游戏的 `Resources`，并将根目录原有的 `ddraw.ini` 移出游戏目录。
3. 打开客户端，在显示设置中选择 **CnC-DDraw** 并保存。客户端会应用新版 DLL 和配置。恢复时关闭游戏和客户端，把备份文件放回原位。

## 构建

用 PowerShell 运行 `./build.ps1 -ToolchainBin <32 位 MinGW-w64 的 bin 目录>`。带日志版和无日志版分别输出到 `dist/regular` 和 `dist/no-log`。

## 许可证

SA_CnCDDraw 的构建脚本、配置和文档采用 [MIT](LICENSE)。CnC-DDraw 上游同样采用 [MIT](vendor/cnc-ddraw-7.1.0.0/LICENSE)，其中的第三方组件沿用各自的许可与版权声明。详见 [第三方声明](THIRD-PARTY-NOTICES.txt)。
