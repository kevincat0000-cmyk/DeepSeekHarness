# DeepSeek Harness 桌面启动器

一键启动 DeepSeek Harness Web 界面（http://127.0.0.1:3080/ ）并自动打开浏览器的 Windows 桌面快捷方式工程。

## 一键安装（推荐）

在 **cmd** 终端粘贴下面这一条命令，即可自动完成全部安装：

1. 把启动器和图标下载到 `%USERPROFILE%\DeepSeekHarness`
2. 用 npm 把 `@deepseek-ai/dsh` 本地部署到该目录
3. 在桌面创建 **DeepSeek Harness** 快捷方式

```cmd
curl -fsSL "https://raw.githubusercontent.com/kevincat0000-cmyk/DeepSeekHarness/main/install.cmd" -o "%TEMP%\dsh-install.cmd" && call "%TEMP%\dsh-install.cmd"
```

安装完成后，双击桌面上的 **DeepSeek Harness** 快捷方式即可启动。

- 前置条件：已安装 [Node.js](https://nodejs.org/)（含 npm）。
- 更新方法：重新运行上面同一条命令即可升级到最新版。
- 快捷方式图标默认使用蓝色图标；如果目录里已有 `DeepSeek-Harness-custom.ico`，则优先使用它。
- 如果系统里没有 curl，可用 PowerShell 代替：

```powershell
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/kevincat0000-cmyk/DeepSeekHarness/main/install.cmd" -OutFile "$env:TEMP\dsh-install.cmd"; & "$env:TEMP\dsh-install.cmd"
```

## 文件说明

| 文件 | 作用 |
| --- | --- |
| `install.cmd` | 一键安装脚本：下载启动器与图标、npm 本地部署 `@deepseek-ai/dsh`、创建桌面快捷方式 |
| `Start-DeepSeek-Harness.cmd` | 启动脚本：检测 3080 端口是否已在运行，未运行则后台启动 `dsh web`，等待就绪后打开浏览器 |
| `DeepSeek-Harness.ico` | 默认蓝色图标（由官方 favicon 生成） |
| `DeepSeek-Harness-custom.ico` | 自定义图标（从自选图片裁剪生成） |
| `make-icon.cjs` | 从官方 favicon.svg 生成默认 .ico 的脚本 |
| `make-icon-custom.cjs` | 把任意图片裁剪为圆角多尺寸 .ico 的脚本 |

## 启动脚本的工作方式

`Start-DeepSeek-Harness.cmd` 会按以下顺序查找运行环境：

1. **Node.js**：`PATH`（`where node.exe`）→ `%ProgramFiles%\nodejs` → `%ProgramFiles(x86)%\nodejs` → `%LOCALAPPDATA%\Programs\nodejs`。
2. **dsh 本体**：优先使用 `DeepSeekHarness\node_modules\@deepseek-ai\dsh\lib\bin.js`（由 `install.cmd` 部署，启动最快）；找不到时回退到 `npx --yes @deepseek-ai/dsh`。
3. 若 3080 端口已有服务在监听，则直接打开浏览器，不重复启动。

## 生成图标

```cmd
node make-icon.cjs
```

两个脚本都使用 [sharp](https://sharp.pixelplumbing.com/)：请先 `npm install sharp`，或把脚本开头的 `require` 路径指向你本机的 sharp。
