# DeepSeek Harness 桌面启动器

一键启动 DeepSeek Harness Web 界面（http://127.0.0.1:3080/ ）并自动打开浏览器的 Windows 桌面快捷方式工程。

## 文件说明

| 文件 | 作用 |
| --- | --- |
| `Start-DeepSeek-Harness.cmd` | 启动脚本：检测 3080 端口是否已在运行，未运行则后台启动 `dsh web`，等待就绪后打开浏览器 |
| `DeepSeek-Harness.ico` | 默认蓝色图标（由官方 favicon 生成） |
| `DeepSeek-Harness-custom.ico` | 自定义图标（从自选图片裁剪生成） |
| `make-icon.cjs` | 从官方 favicon.svg 生成默认 .ico 的脚本 |
| `make-icon-custom.cjs` | 把任意图片裁剪为圆角多尺寸 .ico 的脚本 |

## 使用方法

1. 双击 `Start-DeepSeek-Harness.cmd`；也可以为它创建桌面快捷方式（右键 → 发送到 → 桌面快捷方式），并在属性里把图标换成 `DeepSeek-Harness.ico`。
2. 脚本会先检查 3080 端口：如果 DeepSeek Harness 已在运行就直接打开浏览器，否则在最小化窗口里后台启动服务，最多等待 90 秒。

## 自定义路径

`Start-DeepSeek-Harness.cmd` 顶部有三个路径变量，请按你的环境修改：

```cmd
set "NODE=D:\node.exe"
set "NPX_CLI=D:\node_modules\npm\bin\npx-cli.js"
set "DSH_BIN=C:\Users\<你>\AppData\Local\npm-cache\_npx\<hash>\node_modules\@deepseek-ai\dsh\lib\bin.js"
```

依赖：已安装 Node.js，并曾通过 `npx @deepseek-ai/dsh` 运行过 DeepSeek Harness（`DSH_BIN` 指向 npx 缓存中的安装路径，找不到时会自动回退到 npx 启动）。

## 生成图标

```cmd
node make-icon.cjs
```

两个脚本都使用 [sharp](https://sharp.pixelplumbing.com/)：请先 `npm install sharp`，或把脚本开头的 `require` 路径指向你本机的 sharp。
