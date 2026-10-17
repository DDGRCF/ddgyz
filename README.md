# 🐤 yazi 配置仓库

> **开箱即用的 Yazi 配置合集 —— 插件、主题、快捷键一条龙，clone 下来就能用。**

一套日常在用的 [Yazi](https://github.com/s-yazi/yazi) 终端文件管理器配置，面向中文用户，说明文档全中文 🇨🇳

## 📦 仓库内容

| 文件 / 目录 | 说明 |
| :--- | :--- |
| `yazi.toml` | 管理器、预览器与插件预览规则 |
| `keymap.toml` | 快捷键映射 |
| `init.lua` | 插件初始化与插件参数 |
| `theme.toml` | 界面配色（自定义主题） |
| `package.toml` | 插件与主题依赖清单（`ya pkg` 使用） |
| `plugins/` | 插件本体与文档 |
| `flavors/` | 主题（flavor）资源 |
| `scripts/` | 辅助脚本（配置一键更新） |

## 🚀 快速开始

### 前置要求

1. 安装 [Yazi](https://github.com/s-yazi/yazi)（建议使用较新版本）
2. 确保 `git` 与 `ya` 命令可用（`ya` 随 Yazi 一起提供）

### 安装

```bash
# 1. 备份原有配置（可选，但强烈建议）
mv ~/.config/yazi ~/.config/yazi.bak

# 2. 克隆本仓库作为 Yazi 的配置目录
git clone https://github.com/linxuan-sys/yazi.git ~/.config/yazi

# 3. 按 package.toml 安装插件与主题依赖
cd ~/.config/yazi
ya pkg install
```

完成后启动 `yazi` 即可食用 🍜

## 🔄 更新配置

仓库自带一键更新脚本：

```bash
~/.config/yazi/scripts/update_config.sh
```

不想用脚本的话，手动执行等价的三条命令：

```bash
cd ~/.config/yazi
git fetch --all
git reset --hard origin/main
git clean -fd
ya pkg install
```

> ⚠️ **注意**：两种方式都会强制覆盖本地改动（`reset --hard` + `clean -fd`）。如果你自己改过配置，请先备份或提交，再执行更新。

## 🧩 插件清单（用途 + 依赖）

### 由 `package.toml` 声明（`ya pkg` 管理）

| 插件 | 主要用途 | 额外依赖 / 要求 |
| :--- | :--- | :--- |
| `mediainfo` | 预览音频 / 视频 / 图片 / 字幕的媒体信息 | `mediainfo` CLI；建议 `ImageMagick`；缩略图依赖 `ffmpeg` |
| `full-border` | 给界面加完整边框样式 | 无 |
| `mount` | 磁盘挂载 / 卸载 / 弹出 | Linux：`udisksctl`、`lsblk`、`eject`（来自 `util-linux`）；macOS：`diskutil` |
| `starship` | 集成 starship 提示信息 | `starship` |
| `simple-status` | 精简状态栏显示 | 满足插件要求的 Yazi 版本 |
| `open-with-cmd` | 用自定义命令打开文件 | 无 |
| `gvfs` | 挂载访问 MTP / SMB / SFTP / NFS 等设备 | Linux：`gvfs` + `glib`（按协议安装对应后端） |
| `ouch` | 压缩包预览与压缩解压 | `ouch` |
| `duckdb` | 预览 CSV / TSV / JSON / Parquet / XLSX / DuckDB | `duckdb` CLI |
| `bypass` | 智能跳过单子目录，快速进出 | 无 |
| `augment-command` | 增强默认命令（复制 / 粘贴 / 进入 / 解压等） | `7z` / `7zz`、`file`；可选 `tar` |
| `smart-enter` | 一个按键同时处理「进入目录 / 打开文件」 | 无 |
| `recycle-bin` | 回收站浏览、恢复、永久删除 | `trash-cli` |
| `docx-preview` | `.docx` 文档纯文本预览 | `pandoc` |

### 仓库内置的本地插件

| 插件 | 主要用途 | 额外依赖 / 要求 |
| :--- | :--- | :--- |
| `whoosh` | 书签管理（快速跳转、重命名、删除、历史导航） | 模糊搜索功能建议安装 `fzf` |

> `whoosh` 已在 `init.lua` 中 `require("whoosh"):setup()`，并在 `keymap.toml` 中配置了快捷键。

## 👀 预览能力（当前配置）

在 `yazi.toml` 中已配置：

- 🎬 音频 / 视频 / 图片 → `mediainfo`
- 📊 `csv` / `tsv` / `json` / `parquet` / `xlsx` / `db` / `duckdb` → `duckdb`
- 📝 `*.docx` → `docx-preview`（转纯文本预览）
- 📁 `gvfs` 挂载路径与 `/run/media/*` → `noop`（交给 gvfs 插件处理，避免无效预览）

## ⌨️ 快捷键概览（按插件）

`keymap.toml` 中可见：

- 🔖 `whoosh`：书签增删改查、模糊搜索跳转（绑定最多的插件）
- 💽 `gvfs`：挂载、卸载、弹出、跳转设备
- 🗑️ `recycle-bin`：回收站管理
- 📦 `ouch`：压缩相关操作
- 🧭 `bypass` / `smart-enter`：智能进出目录
- ⚡ `augment-command`：增强命令行为
- 🛠️ `open-with-cmd` / `mount`：自定义命令打开文件、磁盘挂载

## 🎨 主题（flavors）

`package.toml` 已声明安装两个现成主题：

- 🧛 `dracula`
- 🐱 `catppuccin-mocha`

当前 `theme.toml` 使用的是手工自定义配色（未启用 flavor）。想换成现成主题，在 `theme.toml` 里加上：

```toml
[flavor]
dark = "catppuccin-mocha"
```

## 📦 系统依赖总表（一次性备齐）

| 依赖 | 对应功能 |
| :--- | :--- |
| `pandoc` | `.docx` 预览 |
| `duckdb` | 数据文件预览 |
| `mediainfo` | 媒体信息预览 |
| `ffmpeg` | 媒体缩略图（建议） |
| `ImageMagick` | `mediainfo` 插件建议 |
| `starship` | `starship` 插件 |
| `trash-cli` | 回收站插件 |
| `ouch` | 压缩包插件 |
| `7z` / `7zz`、`file` | `augment-command` |
| `fzf` | `whoosh` 模糊搜索（可选） |

Linux 额外需要：`gvfs`、`glib`、`util-linux`（`mount` / `gvfs` 插件）。

Arch Linux 一条命令搞定：

```bash
sudo pacman -S pandoc-cli duckdb mediainfo ffmpeg imagemagick starship trash-cli ouch 7zip file gvfs glib2 util-linux fzf
```

> 💡 其他发行版按上表的工具名安装即可（个别包名有差异：Arch 上 `pandoc` 打包为 `pandoc-cli`，`glib` 对应 `glib2`）。

## ❓ 常见问题

<details>
<summary><b>为什么某些插件装了但功能不可用？</b></summary>

通常是系统命令未安装、或没有加入 `PATH`。对照上面的「系统依赖总表」检查一遍即可。
</details>

<details>
<summary><b>我只想保留部分插件怎么办？</b></summary>

在 `package.toml` 中移除对应依赖，再同步清理 `init.lua` / `keymap.toml` / `yazi.toml` 里的相关配置。
</details>

<details>
<summary><b>更新脚本会覆盖我的修改吗？</b></summary>

会。脚本内部是 `git reset --hard origin/main` + `git clean -fd`，本地未提交的改动会被直接丢弃。想保留修改请先备份或提交。
</details>

<details>
<summary><b>键位用不惯 / 发现键位冲突？</b></summary>

直接编辑 `keymap.toml` 改成自己喜欢的按键即可；如果是本仓库配置本身的键位冲突，欢迎提 Issue 反馈。
</details>

## 🙏 说明

- `plugins/` 与 `flavors/` 中的内容均为上游开源项目的副本，版权归各自作者所有，各目录下附有对应的 `LICENSE` 文件。
- 配置部分（`yazi.toml` / `keymap.toml` / `init.lua` / `theme.toml`）可自由参考、复制、改造。

---

<div align="center">

**如果这套配置帮到了你，欢迎点个 ⭐ Star 支持一下～**

Made with ❤️ by [linxuan-sys](https://github.com/linxuan-sys)

</div>
