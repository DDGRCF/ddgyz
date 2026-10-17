# yazi 配置仓库说明

这是一个面向个人使用的 **Yazi 配置仓库**，包含：

- `yazi.toml`：管理器、预览器与插件预览规则
- `keymap.toml`：快捷键映射
- `init.lua`：插件初始化与插件参数
- `package.toml`：插件与主题依赖清单（`ya pkg` 使用）
- `plugins/`：插件目录（含插件文档）
- `flavors/`：主题目录

---

## 1. 快速上手

### 1.1 前置要求

1. 安装 Yazi（建议使用较新版本，至少满足各插件最低版本要求）
2. 确保 `ya` 包管理命令可用

### 1.2 安装本仓库插件依赖

在本仓库目录执行：

```bash
ya pkg install
```

该命令会根据 `/home/runner/work/yazi/yazi/package.toml` 拉取插件与主题依赖。

---

## 2. 当前插件清单（用途 + 依赖）

> 说明：以下用途与依赖来自本仓库配置及各插件 README。

### 2.1 已在 `package.toml` 声明的插件

| 插件 | 主要用途 | 额外依赖/要求 |
|---|---|---|
| mediainfo | 预览音频/视频/图片/字幕媒体信息 | `mediainfo` CLI；建议安装 `ImageMagick`；缩略图依赖 `ffmpeg`（可用时） |
| full-border | 给 Yazi 界面增加完整边框样式 | 无额外系统依赖 |
| mount | 磁盘挂载/卸载/弹出管理 | Linux: `udisksctl` + `lsblk` + `eject`（通常来自 `util-linux`）；macOS: `diskutil` |
| starship | 在 Yazi 中集成 starship 提示信息 | `starship` |
| simple-status | 精简状态栏显示 | Yazi 版本需满足插件要求 |
| open-with-cmd | 通过自定义命令打开文件 | 无强制额外依赖 |
| gvfs | 挂载并访问本地/远程设备（MTP/SMB/SFTP/NFS 等） | Linux + `gvfs` + `glib`（按协议安装对应 gvfs 后端） |
| ouch | 压缩包预览与压缩操作 | `ouch` 命令需在 `PATH` 中 |
| duckdb | 预览 CSV/TSV/JSON/Parquet/XLSX/DuckDB 数据 | `duckdb` CLI |
| bypass | 智能跳过单子目录进行快速进/退目录 | 无额外系统依赖 |
| augment-command | 增强 Yazi 默认命令（复制/粘贴/进入/解压等） | `7z`/`7zz`、`file`；可选 `tar` |
| smart-enter | 一个按键同时处理“进入目录/打开文件” | 无额外系统依赖 |
| recycle-bin | 回收站浏览、恢复、永久删除 | `trash-cli` |
| docx-preview | `.docx` 文档预览（转纯文本） | `pandoc` |

### 2.2 仓库中存在且已启用的本地插件

| 插件 | 主要用途 | 额外依赖/要求 |
|---|---|---|
| whoosh | 书签管理（快速跳转、重命名、删除、历史导航） | 若使用模糊搜索功能，建议安装 `fzf` |

> `whoosh` 已在 `init.lua` 中 `require("whoosh"):setup()`，并在 `keymap.toml` 配置了快捷键。

---

## 3. 预览能力（当前配置）

在 `/home/runner/work/yazi/yazi/yazi.toml` 中已配置：

- 媒体文件（音视频图片）由 `mediainfo` 预览
- `csv/tsv/json/parquet/xlsx/db/duckdb` 由 `duckdb` 预览
- `.docx` 由 `docx-preview` 预览
- `gvfs` 路径配置为 `noop` 以避免无效预览

---

## 4. 快捷键能力概览（按插件）

`keymap.toml` 中可见：

- `recycle-bin`：回收站管理
- `gvfs`：挂载、卸载、跳转设备
- `whoosh`：书签增删改查与跳转
- `ouch`：压缩相关操作
- `bypass`：智能进入目录
- `augment-command`：增强命令行为
- `open-with-cmd`：自定义命令打开文件
- `mount`：磁盘挂载操作

---

## 5. 主题（flavors）

`package.toml` 当前声明了：

- `dracula`
- `catppuccin-mocha`

可按需在 Yazi 中切换。

---

## 6. 建议安装依赖总表（一次性准备）

不同系统按需安装，建议至少具备：

- `pandoc`（docx 预览）
- `duckdb`（数据文件预览）
- `mediainfo`（媒体信息）
- `ffmpeg`（媒体缩略图，建议）
- `ImageMagick`（mediainfo 插件建议）
- `starship`（starship 插件）
- `trash-cli`（回收站插件）
- `ouch`（压缩插件）
- `7z` 或 `7zz`、`file`（augment-command）
- Linux 额外：`gvfs`、`glib`、`util-linux`（mount/gvfs）
- 可选：`fzf`（whoosh 模糊搜索）

---

## 7. 常见问题

### 为什么某些插件装了但功能不可用？

通常是系统命令未安装或不在 `PATH`，优先检查依赖是否齐全（见上方总表）。

### 我只想保留部分插件怎么办？

可以在 `package.toml` 移除对应依赖，同时在 `init.lua` / `keymap.toml` / `yazi.toml` 删除相关配置。
