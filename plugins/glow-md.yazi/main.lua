-- glow-md.yazi：Markdown 预览首选 —— 用 glow 渲染（标题 / 列表 / 代码块 / 表格）
-- 依赖：glow（Fedora: sudo dnf install glow；Arch: sudo pacman -S glow）
-- glow 不存在时自动回退为纯文本，不会中断预览。
local M = {}

local STYLE = "dark" -- glow 主题：dark / light / notty / auto

---去掉 ANSI 颜色转义，避免控制序列直接出现在预览里
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

---glow 候选路径：PATH 里的 glow，以及常见的用户级安装位置
---@return string[]
local function glow_bins()
  local home = os.getenv("HOME") or ""
  local bins = { "glow" }
  if home ~= "" then
    bins[#bins + 1] = home .. "/.local/bin/glow"
  end
  return bins
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
---@return string? text
---@return string? err
local function render(job)
  local path = tostring(job.file.path or job.file.url)
  local width = math.max(40, (job.area and job.area.w or 80) - 2)
  local last_err

  for _, bin in ipairs(glow_bins()) do
    local output, err = Command(bin):arg({ "-s", STYLE, "-w", tostring(width), path }):output()
    if err then
      last_err = tostring(err)
    elseif output and output.status.success then
      return strip_ansi(output.stdout or ""), nil
    else
      local msg = output and (output.stderr or "") or ""
      msg = msg:gsub("%s+$", ""):gsub("\n", " ")
      if msg ~= "" then
        last_err = msg
      end
    end
  end

  -- glow 不可用（或渲染失败）：回退成纯文本，保证还能看内容
  local raw = read_file(path)
  if raw then
    return raw, nil
  end
  return nil, last_err or "既没有 glow，也无法读取文件"
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
