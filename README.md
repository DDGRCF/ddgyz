# 🐤 Yazi 个人配置（yazi 26.9.1）

> **开箱即用的 Yazi 配置 —— 插件、主题、快捷键一条龙，clone 下来就能用。**

一套面向中文用户、在 **Yazi 官方默认配置** 基础上做增量增强的个人配置：Vim 风格键位、whoosh 书签、GVFS/磁盘挂载、媒体与数据文件预览、Material 风格配色，以及若干**按键冲突修复**。

> 这不是 Yazi 本体，也不是插件合集，而是 `~/.config/yazi` 的 dotfiles 仓库。
> 当前配置在 **Yazi 26.9.1**（Arch Linux 打包版）上使用、验证。

---

## 📦 仓库内容

| 路径 | 规模 | 作用 |
| :--- | ---: | :--- |
| `yazi.toml` | 39 行 | 管理器布局、排序、预加载器/预览器、图片缓存 |
| `keymap.toml` | 445 行 | 全部键位；`[mgr]` 段 150 条映射，另有 `[tasks]` `[spot]` `[pick]` `[input]` `[confirm]` `[cmp]` |
| `theme.toml` | 278 行 | 配色、边框、状态栏、文件类型与图标规则 |
| `init.lua` | 107 行 | 插件初始化与 whoosh / gvfs 参数 |
| `package.toml` | 79 行 | 14 个插件依赖 + 2 个主题 flavor 依赖（锁定 revision / hash） |
| `plugins/` | 15 个目录 | 插件本体；其中 **whoosh 未写入 `package.toml`，需手动安装** |
| `flavors/` | 2 个目录 | `catppuccin-mocha`、`dracula`（当前未启用，见下文） |
| `scripts/update_config.sh` | 1 个脚本 | 强制从 Git 拉取并覆盖本地配置（危险，见「注意事项」） |
| `LICENSE` | — | MIT 许可证 |

---

## 🚀 快速开始

### 前置要求

1. 安装 [Yazi](https://github.com/sxyazi/yazi)（本配置按 **26.9.1** 验证，建议使用较新版本）
2. 确保 `git` 与 `ya` 命令可用（`ya` 随 Yazi 一起提供）

### 安装

```bash
# 1. 备份原有配置（可选，但强烈建议）
mv ~/.config/yazi ~/.config/yazi.bak

# 2. 克隆本仓库作为 Yazi 的配置目录
git clone https://github.com/linxuan-sys/yazi.git ~/.config/yazi

# 3. 按 package.toml 安装 14 个插件与 2 个 flavor
cd ~/.config/yazi
ya pkg install

# 4. whoosh 不在 package.toml 中，需要手动安装
git clone https://gitlab.com/WhoSowSee/whoosh.yazi.git \
  ~/.config/yazi/plugins/whoosh.yazi

# 5. 启动
yazi
```

完成后启动 `yazi` 即可食用 🍜

若只想复用键位而不想装全部插件，至少要保证 `init.lua` 中 `require(...)` 的插件存在，否则 Yazi 启动时会报插件加载错误；可以按需删掉对应的 `require` 行。

### 更新配置

仓库自带一键更新脚本（Yazi 中按 `U`）：

```bash
~/.config/yazi/scripts/update_config.sh
```

脚本行为：交互式确认 → `git fetch --all` → `git reset --hard origin/main` → `git clean -fd` → `ya pkg install`。

> ⚠️ **注意**：这会**丢弃所有本地修改和未跟踪文件**。如果你自己改过配置，或 whoosh 书签、gvfs 挂载记录等运行时数据放在仓库目录内，请先备份或提交，再执行更新。

---

## ✨ 功能特性总览

| 功能 | 说明 | 触发方式 |
| :--- | :--- | :--- |
| 常用目录直达 | Home、Desktop、Downloads、Pictures、Videos、Music、Documents、Public、Templates、`.config`、`.local` | `g` + `h/a/d/p/v/m/w/u/t/c/l`；`g` `<Space>` 交互式输入 |
| Vim 导航 | `h/j/k/l` 移动与进出目录，`gg`/`gb` 首尾，`Ctrl+u/d/b/f` 半页/整页 | 见键位表 |
| 智能进入 | 光标在目录上则进入，在文件上则打开；并自动穿透「仅有一个子目录」的目录链 | `→`（`plugin bypass smart-enter`） |
| 选择后自动下移 | 选中当前项后自动移到下一项，且不循环 | `<Space>`（`toggle` + `augment-command arrow 1 --no-wrap`） |
| 标签页 | 新建、按数字切换、相对切换、交换位置 | `t`、`1`–`9`、`-` `=`、`_` `+` |
| 链接操作 | 相对符号链接、绝对符号链接、硬链接 | `(`、`)`、`*` |
| 文件操作 | 复制/剪切/粘贴、强制粘贴、回收站删除、永久删除、新建；路径复制（`c c/d/f/n`）；多种重命名（`r r/i/a/f`） | `y/x/pp/pf`、`d/D`、`a`、`c` 前缀、`r` 前缀 |
| 搜索与查找 | 智能过滤、查找下一个/上一个、fd 文件名、rg 内容 | `f`、`/`、`?`、`s`、`S` |
| 快速跳转 | fzf 文件/目录、zoxide 目录 | `z`、`Z` |
| 书签（whoosh） | 持久/临时书签、按 key 跳转、fzf 模糊搜索、目录历史 | `[`、`}`、`] a/f/d/r/...`、`<A-k>` |
| 压缩（ouch） | 选择压缩格式并压缩 | `c z` |
| 回收站（recycle-bin） | 浏览、恢复、彻底删除、按天数清理 | `R b` |
| GVFS 挂载 | MTP/SMB/SFTP/WebDAV 等设备与远程存储的挂载、卸载、弹出 | `M m/R/u/U/a/e/r`、`G m`、`` ` ` `` |
| 磁盘挂载（mount） | 基于 `udisksctl` 的本地分区挂载管理 | `M p` |
| 增强预览 | 音视频元数据/缩略图、docx、CSV/JSON/Parquet/Excel/DuckDB | 光标停留即可 |
| 界面 | 全边框、starship 提示符、精简状态栏、Nerd Font 图标 | 启动即生效 |
| 配置自更新 | 从远端强制覆盖本仓库 | `U` |

---

## ⌨️ 快捷键改动说明

### 标签页：四个键保持原样

| 按键 | 行为 | 是否改动 |
| :--- | :--- | :--- |
| `-` | `tab_switch -1 --relative`（上一个标签页） | **不变** |
| `=` | `tab_switch 1 --relative`（下一个标签页） | **不变** |
| `_` | `tab_swap -1`（与上一个标签交换位置） | **不变** |
| `+` | `tab_swap 1`（与下一个标签交换位置） | **不变** |

这四个键被很多人长期使用，属于「肌肉记忆」键位，因此本次修复**刻意不动它们**，只把被它们抢占的链接功能迁走。

### 链接：从 `-` / `_` 迁移到 `(` `)` `&`

| 功能 | 迁移前 | 迁移后 | 结果 |
| :--- | :--- | :--- | :--- |
| 相对符号链接 | `_`（`link --relative`） | `(` | 不再与 `tab_swap -1` 冲突 |
| 绝对符号链接 | `-`（`link`） | `)` | 不再与 `tab_switch -1` 冲突 |
| 硬链接 | `Ctrl` + `-`（旧绑定） | `&` | 一个功能一个入口，并删除本仓库里的重复声明 |

**使用方式**：链接作用于「已 yank 的文件」，生成在「当前所在目录」。所以流程是：

1. 把光标移到源文件上按 `y`（要批量就先 `Space` 多选，再按 `y`）；
2. 跳到目标目录（`h/l`、`g` 系列或任意导航方式都可以，yank 列表不会丢）；
3. 按对应按键：`(` 相对软链 / `)` 绝对软链 / `*` 硬链。

> 三个键的区别：相对软链记录的是目标相对路径，适合在同一棵目录树内使用；绝对软链写死绝对路径；硬链接与原文件共用同一个 inode（等同同一份数据），不受改名影响，但**不能跨文件系统**。

对应的三行配置（`keymap.toml` 第 184–186 行）：

```toml
{ on = ")",  run = "link",            desc = "创建符号链接(绝对路径)" },
{ on = "(",  run = "link --relative", desc = "创建符号链接(相对路径)" },
{ on = "*",  run = "hardlink",        desc = "创建硬链接" },
```

> 说明：Yazi 上游默认键位本身也带有 `Ctrl+-` = 硬链接。本配置删除了自己那份重复声明，但**没有也不能删除上游默认键位**，所以 `Ctrl+-` 依然可用；本仓库显式维护的是 `*`。

### 为什么用 `(` `)` `*` 这三个普通符号键

- `(` / `)` / `*` 分别是 `Shift+9` / `Shift+0` / `Shift+8`，在 Yazi 普通模式下都不与现有键位冲突。
- **为什么不带 `Ctrl`**：kitty 自带 `ctrl+shift+1` … `ctrl+shift+9` / `ctrl+shift+0` = 「聚焦第 1~10 个窗口」的默认快捷键，这几个组合会先被 kitty 吃掉，程序根本收不到。本项目最初确实绑定的是 `Ctrl+(` / `Ctrl+)` / `Ctrl+*`，在 kitty 里实测完全无反应（终端只上报了 Ctrl、Shift 两个修饰键），才改成普通符号键。
- 普通符号键以普通文本形式发送，**不依赖终端键盘协议**，kitty / xterm / tmux 等环境都能用。

### 与 Yazi 上游默认键位的重叠

Yazi 26.9.1 默认用 `[` / `]` 切换标签、`{` / `}` 交换标签。本配置中：

- `[` 被 whoosh 占用为「按 key 跳转书签」；
- `}` 被 whoosh 占用为「直接 fzf 搜索书签」；
- `]` 被 whoosh 用作多键前缀（`] a`、`] f` 等）。

因此**不要依赖上游默认的 `[` `]` `{` `}` 做标签操作**，本配置统一使用 `-` `=` `_` `+`。这是有意为之的取舍，不是遗漏。

---

## 🐛 Bug 修复记录

### Bug 1：`-` / `_` 一个键被两个功能抢占（核心修复）

**症状**

- 按 `-` 时，有时切换到上一个标签页，有时却在当前目录创建符号链接；按 `_` 时，有时交换标签，有时创建相对符号链接。
- 同一个键的行为无法预期，`help` 里也只能看到其中一条说明；用脚本或宏重放按键时结果同样不稳定。

**原因**

- 修复前的 `[mgr] prepend_keymap` 中，同一个 `on` 出现了两条映射：
  - `-` 同时绑定 `tab_switch -1 --relative` 和 `link`（绝对符号链接）；
  - `_` 同时绑定 `tab_swap -1` 和 `link --relative`（相对符号链接）。
- Yazi 对同一键位的多条映射最终只让其中一条生效，另一条被静默覆盖；命中的是哪一条取决于配置合并/加载顺序，所以表现为「时灵时不灵」，升级或增删键位后还可能变化。

**修复**

- 从 `[mgr] prepend_keymap` 中删除 `-` 和 `_` 上的两条链接绑定。
- 四个标签键 `-` `=` `_` `+` **原样保留**，保证老用户的习惯不被破坏。
- 三个链接功能迁移到未被占用的 `Ctrl` + 符号键：
  - `(` → `link --relative`（相对符号链接）
  - `)` → `link`（绝对符号链接）
  - `*` → `hardlink`（硬链接）

**验证**

- `[mgr]` 段内 `-` 与 `_` 现在各只剩一条映射（第 112、114 行，均为标签操作）；链接操作只剩第 184–186 行这三条。
- 用 TOML 解析器逐段校验，全部 272 条映射无同键重复（见下方自查表）。

### Bug 2：硬链接存在两个入口

**症状**

- 旧配置把硬链接绑在 `Ctrl` + `-`，迁移方案又新增了一个硬链接键；两个键做同一件事，容易误触，也让键位表显得混乱。

**原因**

- 迁移时只考虑了「把链接功能搬走」，没有同时清理旧的硬链接声明，形成同功能重复绑定。

**修复**

- 删除本仓库里原来的 `Ctrl` + `-` 硬链接声明，只保留 `*`（上游默认的 `Ctrl+-` 仍作为 Yazi 自带键位存在）。
- 现在链接类操作在配置中固定为三个键，一个功能一个入口，不再有重叠。

### Bug 3：目录被显示成「可执行文件」图标

**症状**

- 普通目录偶尔显示成可执行文件的齿轮图标，而不是文件夹图标，目录和文件的视觉区分被打乱。

**原因**

- `theme.toml` 的 `[icon]` 规则中，可执行文件条件只写了 `if = "exec"`。Linux 目录默认带 `x` 权限，会命中该规则；若它排在目录规则之前，目录就先被当成可执行文件。

**修复**

- 可执行文件规则改为 `if = "exec & !dir"` 显式排除目录，并把 `if = "dir"` 规则提前，保证目录优先匹配文件夹图标（见 `theme.toml` 第 195、203 行）。

### 重复键位自查结果

用 TOML 解析器逐段统计 `on` 字段，结果如下（同一段内）：

| 段 | 映射条数 | 唯一键数 | 重复 |
| :--- | ---: | ---: | :--- |
| `[mgr]` | 150 | 150 | 无 |
| `[tasks]` | 12 | 12 | 无 |
| `[spot]` | 15 | 15 | 无 |
| `[pick]` | 10 | 10 | 无 |
| `[input]` | 62 | 62 | 无 |
| `[confirm]` | 12 | 12 | 无 |
| `[cmp]` | 11 | 11 | 无 |

合计 272 条映射，**其余按键已校验无重复**。以下情况容易被误判为「重复」，均**不是冲突**：

- `}` 与 `] f` 都执行 `plugin whoosh jump_by_fzf`：`}` 是单键快捷入口，`] f` 是放在 `]` 前缀组里的同一功能，属于「同功能双入口」。
- `Y` 与 `X` 都执行 `unyank`：一个沿袭 Vim 的「复制」，一个沿袭「剪切」，取消状态时合并为同一动作。
- `r f` 与 `r c` 都执行 `rename -- --empty=all`：为兼容不同习惯保留的两个入口。
- `~` 与 `Ctrl+F1`（`[mgr]`）、`~` 与 `F1`（其他面板）都打开帮助：键盘/功能键两套入口。
- `[`、`}` 与上游默认的标签键重叠，见上一节，属于有意覆盖。

> 结论：当前配置**没有**「同一个键绑定两个不同功能」的残留。

---

## 🧩 插件清单

`package.toml` 固定了 14 个插件的 revision 与 hash；`plugins/` 下实际有 15 个，**whoosh 不在 `package.toml` 中**，需要手动安装。

| 插件 | 作用 | 本配置中的入口 / 依赖 |
| :--- | :--- | :--- |
| `augment-command` | 增强/新增 Yazi 命令（open、enter、rename、shell、archive、平滑滚动等） | 只用了 `arrow 1 --no-wrap`（`<Space>` 选中后下移不循环）；若使用其解压/归档功能需 `7z`、`file` |
| `bypass` | 进入/返回时跳过「仅含单个子目录」的目录链 | `→` = `plugin bypass smart-enter` |
| `docx-preview` | 用 `pandoc` 把 `.docx` 转纯文本并分页预览，支持中文 | `yazi.toml` 的 `*.docx` 预览器；依赖 `pandoc` |
| `duckdb` | 用 DuckDB 预览/汇总 CSV、TSV、JSON、Parquet、XLSX、DB | `yazi.toml` 中的多个 previewer；依赖 `duckdb` CLI |
| `full-border` | 给管理器三栏加完整圆角边框 | `init.lua` 的 `require("full-border"):setup()` |
| `gvfs` | 通过 gvfs/gio 挂载、卸载、弹出设备与远程存储，支持保存 URI 和密码 | `M m/R/u/U/a/e/r`、`G m`、`` ` ` ``；依赖 `gvfs`、`glib`，密码库用 `keyring` 时需 `secret-tool` |
| `mediainfo` | 用 `ffmpeg` 生成音视频/图片缩略图，用 `mediainfo` 读取元数据 | `yazi.toml` 的 preloader/previewer；依赖 `ffmpeg`、`mediainfo` |
| `mount` | 基于 `udisksctl`/`lsblk`/`eject` 的磁盘分区挂载管理 | `M p`；依赖 `udisks2`、`util-linux` |
| `open-with-cmd` | 弹出输入框，用自定义命令打开文件，可选阻塞模式 | `o c`（`--block`）；无额外依赖 |
| `ouch` | 用 `ouch` 压缩/解压 | `c z` 压缩；依赖 `ouch`（插件本身支持压缩包预览，但本配置未接入该预览器） |
| `recycle-bin` | 回收站菜单：浏览、恢复、彻底删除、按天数清理 | `R b`；依赖 `trash-cli`；上游已标记 deprecated |
| `simple-status` | 精简状态栏（文件数、大小、权限、所有者等） | `init.lua` 的 `require("simple-status"):setup()` |
| `smart-enter` | 目录则进入、文件则打开的「二合一」动作 | 未直接绑定；`→` 通过 `bypass smart-enter` 使用同类能力 |
| `starship` | 在 Yazi 顶部渲染 starship 提示符 | `init.lua` 的 `require("starship"):setup()`；依赖 `starship` |
| `whoosh` | 键盘优先的书签管理：持久/临时书签、fzf 搜索、目录历史 | `[`、`}`、`] a/A/t/T/f/d/D/C/r/R`、`<A-k>`；依赖 `fzf` |

---

## 👀 预览能力（`yazi.toml`）

- 🎬 预加载：`{audio,video,image}/*` → `mediainfo`；GVFS 挂载点 `/run/user/1000/gvfs/**/*`、`/run/media/USER_NAME/**/*` → `noop`（避免对虚拟文件系统做无意义预加载）。
- 📊 预览：媒体 → `mediainfo`；字幕/PostScript → `mediainfo`；目录 → `folder`；CSV/TSV/JSON/Parquet/XLSX/DB/DuckDB → `duckdb`；`.docx` → `docx-preview`。
- 🖼️ `[tasks] image_alloc = 1073741824`，即图片缓存上限约 **1 GiB**，内存紧张时可下调。

---

## 🎨 主题与外观

`theme.toml` 是一套手写的 Material 风格深色主题，**不是**通过 flavor 加载的：

- 主色 `#bec2ff`（边框、标签、提示、目录名），第三色 `#e7b9d5`（选中项、部分图标），错误色 `#ffb4ab`（查找关键字、警告），表面色 `#131318`。
- `[which] cols = 3`：按键提示面板三列显示，分隔符为 ` ▶ `；`[mgr] border_symbol = "│"` 配合 `full-border` 形成完整边框。
- `[status]` 使用 `🭁` / `🭠` 作为左右分隔符；`[indicator]` 用 `█` 包裹当前项。
- `[icon]` 分四层：`prepend_conds`（目录、链接、孤儿链接、可执行、隐藏）、`prepend_dirs`（Desktop/Documents/Downloads 等）、`prepend_exts`（图片、音视频、压缩包、代码/配置）、`prepend_files`（`PKGBUILD`、`README.md`、`Makefile`、`.bashrc`、`.zshrc`）。
- 图标依赖 **Nerd Font**；终端字体未打补丁时这些字形会显示成方块。

### flavors 为什么没生效

`package.toml` 声明并安装了 `catppuccin-mocha` 与 `dracula` 两个 flavor，但 `theme.toml` 中**没有 `[flavor]` 段**，所以它们目前不会被加载，实际配色完全来自 `theme.toml`。

如果想临时切换，可在 `theme.toml` 末尾加入（这是 Yazi 的标准用法，非本仓库现有内容）：

```toml
[flavor]
dark = "catppuccin-mocha"
light = "catppuccin-mocha"
```

加入后 `theme.toml` 里的自定义颜色仍会覆盖 flavor 中同名的键，二者是叠加关系。

---

## 📦 系统依赖总表（一次性备齐）

| 依赖 | 对应功能 | 不装的后果 |
| :--- | :--- | :--- |
| `fzf` | whoosh 模糊搜索、`z` 跳转 | 书签 fzf 功能与 `z` 不可用 |
| `zoxide` | `Z` 目录跳转 | `Z` 不可用 |
| `fd` / `rg` | `s` / `S` 搜索 | 对应搜索不可用 |
| `ffmpeg` + `mediainfo` | 媒体缩略图与元数据 | 媒体预览退化 |
| `duckdb` | 表格/数据库预览 | CSV/JSON/Parquet 等无法预览 |
| `pandoc` | `.docx` 预览 | docx 显示错误提示 |
| `ouch` | 压缩/解压 | `c z` 不可用 |
| `trash-cli` | recycle-bin 插件 | `R b` 菜单不可用（Yazi 原生回收站仍可用） |
| `gvfs` + `glib`（`gio`） | GVFS 挂载 | `M` 系列键不可用 |
| `udisks2` + `util-linux` | mount 插件 | `M p` 不可用 |
| `starship` | 顶部提示符 | 提示符为空/报错 |
| `7z`、`file` | augment-command 的解压/归档能力 | 本配置只用到 `arrow`，一般不影响 |

Arch Linux 一条命令搞定：

```bash
sudo pacman -S pandoc-cli duckdb mediainfo ffmpeg imagemagick starship trash-cli ouch 7zip file gvfs glib2 util-linux fzf
```

> 💡 其他发行版按上表的工具名安装即可（个别包名有差异：Arch 上 `pandoc` 打包为 `pandoc-cli`，`glib` 对应 `glib2`）。

---

## ❓ 常见问题

<details>
<summary><b>为什么某些插件装了但功能不可用？</b></summary>

通常是系统命令未安装、或没有加入 `PATH`。对照上面的「系统依赖总表」检查一遍即可。
</details>

<details>
<summary><b>链接键按不出来怎么办？</b></summary>

链接键用的是普通符号键 `(`、`)`、`*`，不依赖终端键盘协议，正常终端都能用。如果你的键盘布局打不出这些符号，编辑 `keymap.toml` 换成你顺手的未占用键即可。
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

---

## ⚠️ 注意事项 / 已知限制

1. **链接键为什么不用 `Ctrl`**：kitty 默认把 `ctrl+shift+1`…`ctrl+shift+9`、`ctrl+shift+0` 当作「聚焦第 N 个窗口」，`Ctrl+(` / `Ctrl+)` / `Ctrl+*` 会被终端优先截获、程序收不到（本项目曾这样绑定过，实测无效）。因此改为普通符号键 `(`、`)`、`*`。
2. **`[` / `}` 覆盖了上游标签键**：whoosh 占用 `[`、`}`，`]` 作为前缀；标签操作请统一用 `-` `=` `_` `+`。
3. **whoosh 需手动安装，书签易丢**：它不在 `package.toml` 中，`ya pkg install` 不会安装或更新；书签文件 `plugins/whoosh.yazi/bookmarks`（当前 0 字节）就在插件目录内，升级/重装或被 `git clean -fd` 清理都会丢失，请先备份。另外 `init.lua` 第 10 行 `bookmarks = bookmarks` 的右侧变量未定义，实际传入 `nil`，配置书签为空；要预置需先写 `local bookmarks = { ... }`。
4. **`yazi.toml` 有两处需按环境调整**：`/run/media/USER_NAME/**/*` 的 `USER_NAME` 是字面占位符，需替换成实际用户名；目录预览使用 `{ url = "*/", run = "folder" }`，而 gvfs README 建议 26.8.15+ 改为 `folder/*`，若目录预览异常可调整。
5. **部分插件上游已弃用**：`gvfs`、`mediainfo`、`recycle-bin` 的 README 都标注了 deprecated。Yazi 26.8.15+ 已内置回收站浏览（默认 `g` → `t`），可以不依赖 `recycle-bin`；保留它是为了 `R b` 菜单和按天数清理。
6. **GVFS 与缓存参数**：`password_vault = "keyring"` 需要 `secret-tool` 与可用 keyring；`key_grip = "BBBB..."` 只是 `pass` 方案的占位符；`image_alloc = 1 GiB` 对低内存机器偏大，可在 `yazi.toml` 中下调。
7. **仅验证了 Linux**：GVFS、mount、回收站路径均为 Linux 方案；Windows/macOS 需自行调整。

---

## 📄 许可证与致谢

- 本仓库的配置文件（`yazi.toml` / `keymap.toml` / `theme.toml` / `init.lua` / `README.md` 等）以 **MIT License** 发布，见 [`LICENSE`](./LICENSE)。
- `plugins/` 与 `flavors/` 中的内容均为上游开源项目的副本，版权归各自作者所有，各目录下附有对应的 `LICENSE` 文件。

---

<div align="center">

**如果这套配置帮到了你，欢迎点个 ⭐ Star 支持一下～**

Made with ❤️ by [linxuan-sys](https://github.com/linxuan-sys)

</div>
