<div align="center">
  <img src="./apps/app/icons/128x128.png" width="128" height="128" alt="TaCraft Player Community Logo" />
  <h1>TaCraft Player Community</h1>
  <p><strong>为 TCS 社区打造的 Minecraft 桌面启动器。</strong></p>

  <p>
    <a href="COPYING.md">
      <img src="https://img.shields.io/badge/License-GPL_3.0-blue.svg?style=for-the-badge" alt="License" />
    </a>
    <a href="https://www.tcscraft.com">
      <img src="https://img.shields.io/badge/TCS-Community-ff8c1a?style=for-the-badge" alt="TCS Community" />
    </a>
  </p>

  <p>
    <a href="https://www.tcscraft.com">社区论坛</a> ｜
    <a href="CONTRIBUTING.md">参与贡献</a>
  </p>
</div>

---

**TaCraft Player Community** 是一款免费、开源的 Minecraft Java 版第三方启动器，基于 [Axolotl Launcher](https://github.com/Axolotl-Launcher/Axolotl) 定制，面向 TCS 社区分发。

支持在一个客户端中搜索、安装和更新来自 Modrinth 与 CurseForge 的模组、整合包、资源包和光影，并提供实例管理、多种账户认证与实验室工具。

> 本项目是**非官方社区定制版**，与 Axolotl Launcher 上游团队、Mojang、Microsoft 及 Rinth, Inc. 均无关联。

## 这一版改了什么

- **橙白配色 + 浅色主题 + 中文开箱即用**：默认浅色主题、橙色强调色、简体中文界面；老用户若仍是旧的默认设置，会在升级时自动迁移。
- **界面只保留简体中文与 English (US)**：去掉其余语言包，减少体积。
- **内置社区入口**：侧边栏新增「论坛」
- **去掉启动器自动更新**：本版不包含启动器自身的更新器，版本手动跟进。
- **精简设置面板**：移除「更新」「隐私与数据共享」「第三方账户」「AI 功能」四个设置页。
- **精简关于页**：只保留版本信息、许可证署名与新手引导重播入口。
- **去掉启动画面与美西螈形象**：不再有启动 Splash 与像素美西螈素材。
- **数据目录改为 `%APPDATA%\TCS-Community`**：与上游的 `red.ghs.axolotl` 分开，两者互不影响，旧目录里的实例不会自动迁移。

## 核心能力

- **跨平台**：Windows、macOS（Intel / Apple Silicon）与主流 Linux 发行版。
- **内容生态**：集成 Modrinth 与 CurseForge，实例、整合包、模组、资源包、光影一键安装与升级。
- **个性化**：主题色调、强调色、背景图片、离线皮肤均可自定义。
- **实验室工具箱**：种子地图、投影工坊等内置工具。

## 技术栈

- **桌面运行时（Rust / Tauri 2）**：`packages/app-lib` 提供强类型实例管理、SQLite 状态持久化、迁移控制与多线程下载引擎；`apps/app` 是基于 Tauri 2 的原生壳，负责 IPC 与系统集成。
- **前端（Vue 3 / Vite / Tailwind CSS）**：`apps/app-frontend` 为桌面界面，`apps/website` 为官网，共享设计系统 `packages/ui`。
- **生态集成**：`packages/content-management`、`packages/api-client` 对接 Modrinth 与 CurseForge 公开 API。
- **账户**：Microsoft 正版登录、Yggdrasil 第三方验证、离线账户。

## 本地构建

仓库是 pnpm workspace + turbo 的 monorepo。子模块（`apps/app/vendor/cubiomes`、`third-party/blockbench`）必须先初始化，否则种子地图和皮肤编辑器都编不出来。

```bash
git submodule update --init --depth 1
pnpm install
```

**前端单独构建**：

```bash
cd apps/app-frontend
node node_modules/vite/bin/vite.js build
```

**桌面端（Linux 本机）**：

```bash
cd apps/app
cargo build --release
```

**交叉编译 Windows x64**（需要 `cargo-xwin`、`clang`、`mingw-w64-gcc`）：

```bash
export CFLAGS="-msse4.1 -mssse3"
export CXXFLAGS="$CFLAGS"
export AXOLOTL_CUBIOMES_CC=x86_64-w64-mingw32-gcc
cargo xwin build --release --target x86_64-pc-windows-msvc \
  --manifest-path apps/app/Cargo.toml --features custom-protocol -j 1
```

产物为 `target/x86_64-pc-windows-msvc/release/theseus_gui.exe`，发布时还需要把 `apps/app/resources/`（含 `seed-map`、`blockbench-skin`）放到 exe 同级的 `resources` 目录。

## Windows 构建

在 Windows 上直接原生编译，不需要交叉工具链。

**前置依赖**

| 依赖                   | 说明                                                      |
| ---------------------- | --------------------------------------------------------- |
| Rust                   | rustup 安装，默认 MSVC 工具链                             |
| Visual Studio 生成工具 | 勾选「使用 C++ 的桌面开发」，提供 MSVC 与 Windows SDK     |
| Node.js                | 24.11+ 或 22.21+（更老的版本会被 workspace 拒绝）         |
| pnpm                   | 10.x，`corepack enable pnpm`                              |
| MinGW-w64 gcc          | MSYS2 的 `mingw-w64-x86_64-gcc`，用于编译种子地图引擎 DLL |

MinGW 是硬性依赖：`apps/app/build.rs` 在 Windows 目标下直接调用 gcc 构建 `axolotl-cubiomes.dll`，缺了会停在 `MinGW cubiomes engine build failed`。gcc 不在 `PATH` 里时用环境变量指定：

```bat
set AXOLOTL_CUBIOMES_CC=C:\msys64\mingw64\bin\gcc.exe
```

**打成安装包**

```bat
cd apps/app
pnpm build
```

会依次完成前端构建、Rust 编译和 NSIS 打包，安装包产物在 `target\release\bundle\nsis\`。安装模式是 `currentUser`，不需要管理员权限。

**只出可执行文件**

```bat
cargo build --release --features custom-protocol
```

产物是 `target\release\theseus_gui.exe`。运行前要把 `apps\app\resources\`（含 `seed-map`、`blockbench-skin`）拷成 exe 同级的 `resources` 目录，否则种子地图和皮肤编辑器的资源会缺失。

首次编译时 `build.rs` 会自己 `npm ci` 并构建皮肤编辑器资源，需要联网和 `PATH` 里的 node。临时跳过可以设 `AXOLOTL_SKIP_BLOCKBENCH_BUILD=1`，但跳过之后打包会因为缺少 `resources/blockbench-skin` 直接失败，只适合改 Rust 逻辑时的快速迭代。

## 社区

- 论坛：<https://www.tcscraft.com>
- 问题反馈：本仓库的 Issues

## 许可证

本项目沿用上游的 **GPL-3.0** 许可证，详见 [COPYING.md](COPYING.md)。

原项目：[Axolotl Launcher](https://github.com/Axolotl-Launcher/Axolotl)（GPL-3.0），上游又基于 [Modrinth App](https://github.com/modrinth/code)。感谢上游所有贡献者。
