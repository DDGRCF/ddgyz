-- glow-md.yazi：用 glow 渲染 Markdown 预览（yazi 的 Markdown 预览首选）
-- 依赖：glow（Fedora: sudo dnf install glow；Arch: sudo pacman -S glow）
-- glow 不存在时自动回退为纯文本预览，不会报错中断。
local M = {}

local STYLE = "dark" -- glow 主题：dark / light / notty / auto
local SUFFIX = { ".md", ".markdown", ".mdown", ".mkd" }

---去掉 ANSI 颜色转义，避免终端控制序列直接显示在预览里
---@param s string
---@return string
local function strip_ansi(s)
  return (s:gsub("\27%[[%d;?]*[a-zA-Z]", ""))
end

---@param path string
---@return string?
local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end

---@param s string
---@return string[]
local function to_lines(s)
  local lines = {}
  for line in (s:gsub("\r\n", "\n") .. "\n"):gmatch("([^\n]*)\n") do
    -- glow 会用空格把行补齐到指定宽度，去掉行尾空白
    lines[#lines + 1] = (line:gsub("[ \t]+$", ""))
  end
  return lines
end

---@param job Job
---@return string? text, string? err
local function render(job)
  local path = tostring(job.file.path or job.file.url)
  local width = math.max(40, (job.area and job.area.w or 80) - 2)

  local output, err = Command("glow"):arg({ "-s", STYLE, "-w", tostring(width), path }):output()
  if err then
    -- glow 未安装：回退到纯文本
    local raw = read_file(path)
    if raw then
      return raw
    end
    return nil, tostring(err)
  elseif not output or not output.status.success then
    local msg = output and (output.stderr or "") or ""
    msg = msg:gsub("%s+$", ""):gsub("\n", " ")
    if msg == "" then
      return read_file(path) or ""
    end
    return nil, msg
  end

  return strip_ansi(output.stdout or "")
end

---@param job Job
function M:peek(job)
  local text, err = render(job)
  if not text then
    ya.preview_widget(
      job,
      ui.Text({
        ui.Line({ ui.Span("Markdown 预览失败"):style(ui.Style():fg("red"):bold()) }),
        ui.Line({}),
        ui.Line({ ui.Span(tostring(err)):style(ui.Style():fg("yellow")) }),
        ui.Line({ ui.Span("提示：安装 glow 后可高亮渲染 → sudo dnf install glow"):style(ui.Style():fg("blue")) }),
      }):area(job.area):wrap(ui.Wrap.YES)
    )
    return
  end

  local rows = to_lines(text)
  local height = math.max(1, (job.area and job.area.h) or 20)
  local skip = math.max(0, job.skip or 0)
  local page = {}
  for i = skip + 1, math.min(skip + height, #rows) do
    page[#page + 1] = ui.Line({ ui.Span(rows[i]) })
  end

  ya.preview_widget(job, ui.Text(page):area(job.area))
end

---@param job Job
function M:seek(job)
  local h = cx.active.current.hovered
  if h and h.url == job.file.url then
    local height = math.max(1, (job.area and job.area.h) or 20)
    local step = ya.clamp(-height, job.units, height)
    ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
  end
end

return M
