--- @since 26.9.1
-- video-tools.yazi
-- W c：压缩视频到指定大小（单遍 ABR / libx264 preset medium）
-- W C：截取视频某一段（起-止 或 起+时长）
-- 依赖：ffmpeg + ffprobe
-- 说明：yazi 26.9 起插件 entry 默认在异步上下文运行，拿不到全局 cx，
--       所以「当前悬停文件」用 ya.sync() 回主线程取；ya.input 必须显式给 pos。
local M = {}

---@param title string
---@param content string
---@param level string?
---@param timeout number?
local function notify(title, content, level, timeout)
  ya.notify({ title = title, content = content, level = level or "info", timeout = timeout or 6 })
end

---主线程取当前悬停文件（ya.sync 回调不能捕获 upvalue）
---@type fun(): string?, number
local hovered = ya.sync(function()
  local h = cx.active.current.hovered
  if not h then
    return nil, 0
  end
  if h.cha and h.cha.is_dir then
    return "<dirname>" .. tostring(h.name), 0
  end
  local ok, n = pcall(function() return h:size() end)
  return tostring(h.path), (ok and type(n) == "number") and n or 0
end)

---@param title string
---@param value string?
---@return string?
local function ask(title, value)
  local v, event = ya.input({
    pos = { "top-center", y = 2, w = 70 },
    title = title,
    value = value or "",
  })
  if event ~= 1 then
    return nil
  end
  return v
end

--==================== 通用小工具 ====================--

---@param s string
---@return string
local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

---@param path string
---@return number
local function file_size(path)
  local f = io.open(path, "rb")
  if not f then
    return 0
  end
  local n = f:seek("end") or 0
  f:close()
  return n
end

---@param path string
---@return boolean
local function exists(path)
  local f = io.open(path, "rb")
  if not f then
    return false
  end
  f:close()
  return true
end

---/a/b/c.mp4 → "/a/b", "c"
---@param path string
---@return string dir
---@return string base
local function split_path(path)
  local dir, name = path:match("^(.*)/([^/]+)$")
  if not dir then
    return ".", path
  end
  local base = name:match("^(.*)%.[^%.]+$") or name
  return dir, base
end

---@param path string
---@return string
local function basename(path)
  return path:match("([^/]+)$") or path
end

---输出文件已存在时自动加 (2)(3)…，绝不覆盖
---@param path string
---@return string
local function unique_path(path)
  if not exists(path) then
    return path
  end
  local stem, ext = path:match("^(.*)(%.[^./]+)$")
  if not stem then
    stem, ext = path, ""
  end
  for i = 2, 999 do
    local cand = string.format("%s (%d)%s", stem, i, ext)
    if not exists(cand) then
      return cand
    end
  end
  return path
end

---秒 → 00:01:23
---@param t number
---@return string
local function hms(t)
  local s = math.floor(t + 0.5)
  return string.format("%02d:%02d:%02d", math.floor(s / 3600), math.floor((s % 3600) / 60), s % 60)
end

---秒 → 00.01.23（文件名里不能有冒号）
---@param t number
---@return string
local function hms_file(t)
  return (hms(t):gsub(":", "."))
end

---"90" / "1:30" / "01:02:03" / "1h2m3s" / "90.5" → 秒
---@param s string
---@return number?
local function to_secs(s)
  s = trim(s):gsub("：", ":")
  if s == "" then
    return nil
  end

  local h, m, sec = s:match("^(%d+):(%d+):(%d+%.?%d*)$")
  if h then
    return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(sec)
  end

  local m2, s2 = s:match("^(%d+):(%d+%.?%d*)$")
  if m2 then
    return tonumber(m2) * 60 + tonumber(s2)
  end

  local hh = s:match("(%d+%.?%d*)h")
  local mm = s:match("(%d+%.?%d*)m")
  local ss = s:match("(%d+%.?%d*)s")
  if hh or mm or ss then
    return (tonumber(hh) or 0) * 3600 + (tonumber(mm) or 0) * 60 + (tonumber(ss) or 0)
  end

  return tonumber(s)
end

--==================== 探测与执行 ====================--

---ffprobe：时长 + 文件大小，并确认有视频轨
---@param path string
---@return { duration: number, size: number }? info
---@return string? err
local function probe(path)
  local out, err = Command("ffprobe"):arg({
    "-v", "error",
    "-select_streams", "v:0",
    "-show_entries", "stream=codec_type:format=duration,size",
    "-of", "default=noprint_wrappers=1",
    "--", path,
  }):output()

  if not out then
    return nil, "调用 ffprobe 失败：" .. tostring(err) .. "（请先安装 ffmpeg）"
  end
  if not out.status.success then
    local msg = trim(out.stderr or "")
    return nil, "ffprobe 读取失败：" .. (msg ~= "" and msg or "无法解析该文件")
  end

  local info = {}
  for line in tostring(out.stdout or ""):gmatch("[^\r\n]+") do
    local k, v = line:match("^([%w_]+)=(.*)$")
    if k then
      info[k] = v
    end
  end

  local duration = tonumber(info.duration)
  local size = tonumber(info.size) or 0
  if info.codec_type ~= "video" then
    return nil, "这不是视频文件（没有视频轨）"
  end
  if not duration or duration <= 0 then
    return nil, "读不到视频时长，无法处理"
  end
  if size <= 0 then
    size = file_size(path)
  end

  return { duration = duration, size = size }
end

---跑 ffmpeg，失败时把 stderr 原样弹出来
---@param args string[]
---@param label string
---@return boolean
local function run_ffmpeg(args, label)
  notify("视频处理", label .. "：已开始，完成后会再提示（大文件可能几分钟）", "info", 6)

  local out, err = Command("ffmpeg"):arg(args):output()
  if not out then
    notify("视频处理", label .. " 启动失败：" .. tostring(err) .. "（请先安装 ffmpeg）", "error", 12)
    return false
  end
  if not out.status.success then
    local msg = trim(out.stderr or "")
    if msg == "" then
      msg = "ffmpeg 退出码 " .. tostring(out.status.code)
    end
    if #msg > 700 then
      msg = "…" .. msg:sub(-700)
    end
    notify("视频处理", label .. "失败：\n" .. msg, "error", 15)
    return false
  end
  return true
end

--==================== W c：压缩到指定大小 ====================--

local function cmd_compress()
  local path, size = hovered()
  if not path or path == "" then
    return notify("视频处理", "没有选中任何文件", "warn", 4)
  end
  if path:sub(1, 9) == "<dirname>" then
    return notify("视频处理", "选中的是文件夹，请选中一个视频文件", "warn", 4)
  end

  local orig_mb = size / 1048576
  if orig_mb > 0 and orig_mb <= 0.2 then
    return notify("视频处理", "文件太小，没什么可压的", "warn", 5)
  end

  local hint = orig_mb > 0 and string.format("原文件 %.1f MB", orig_mb) or "输入数字即可"
  local def = orig_mb > 0 and tostring(math.max(1, math.floor(orig_mb * 0.5))) or ""
  local answer = ask(string.format("压缩到多少 MB？（%s）", hint), def)
  if not answer then
    return
  end

  local mb = tonumber((answer:gsub("[^%d%.]", "")))
  if not mb or mb <= 0 then
    return notify("视频处理", "目标大小无效，请输入数字（单位 MB）", "error", 6)
  end
  if orig_mb > 0 and mb >= orig_mb then
    return notify("视频处理", string.format("目标 %.0f MB ≥ 原文件 %.1f MB，不需要压缩", mb, orig_mb), "warn", 6)
  end

  local info, perr = probe(path)
  if not info then
    return notify("视频处理", perr, "error", 10)
  end

  local dur = info.duration
  -- 单遍 ABR：总码率 = 目标字节 ÷ 时长，减去音频码率即视频码率
  local audio_kbps = 128
  local total_kbps = mb * 8192 / dur
  local video_kbps = math.floor(total_kbps - audio_kbps)
  if video_kbps < 100 then
    local min_mb = math.ceil((dur * (100 + audio_kbps)) / 8192)
    return notify("视频处理",
      string.format("目标 %.0f MB 太小：这段 %s 的视频至少要 %d MB", mb, hms(dur), min_mb), "error", 12)
  end

  local dir, base = split_path(path)
  local out = unique_path(string.format("%s/%s_压缩%dMB.mp4", dir, base, math.floor(mb + 0.5)))

  local ok = run_ffmpeg({
    "-y", "-hide_banner", "-loglevel", "error",
    "-i", path,
    "-map", "0:v:0", "-map", "0:a?",
    "-c:v", "libx264", "-preset", "medium", "-profile:v", "high", "-pix_fmt", "yuv420p",
    "-b:v", video_kbps .. "k",
    "-maxrate", math.floor(video_kbps * 1.5) .. "k",
    "-bufsize", (video_kbps * 3) .. "k",
    "-c:a", "aac", "-b:a", audio_kbps .. "k", "-ac", "2",
    "-sn", "-dn", "-map_metadata", "0", "-movflags", "+faststart",
    out,
  }, "压缩")
  if not ok then
    return
  end

  ya.emit("refresh", {})
  notify("视频处理",
    string.format("压缩完成：%s\n%.1f MB → %.1f MB", basename(out), info.size / 1048576, file_size(out) / 1048576),
    "info", 12)
end

--==================== W C：截取时间段 ====================--

---"起-止" / "起+时长" → 起止秒
---@param s string
---@param dur number
---@return number? start
---@return number? stop
---@return string? err
local function parse_range(s, dur)
  s = trim(s):gsub("%s", "")
  if s == "" then
    return nil, nil, "请输入时间段，例如 00:10-01:00 或 00:10+30"
  end

  local mode, a, b = "range", s:match("^([^-]*)%-(.*)$")
  if not a then
    mode, a, b = "dur", s:match("^([^%+]*)%+(.*)$")
  end
  if not a then
    return nil, nil, "格式看不懂，示例：00:10-01:00 / 00:10+30 / 00:10-"
  end

  local start = (a == "") and 0 or to_secs(a)
  if not start then
    return nil, nil, "起点时间无效：" .. a
  end

  local stop
  if mode == "dur" then
    local d = to_secs(b)
    if not d or d <= 0 then
      return nil, nil, "时长无效：" .. b
    end
    stop = start + d
  elseif b == "" then
    stop = dur
  else
    stop = to_secs(b)
    if not stop then
      return nil, nil, "终点时间无效：" .. b
    end
  end

  if start >= dur then
    return nil, nil, string.format("起点 %s 超出视频长度 %s", hms(start), hms(dur))
  end
  if stop > dur then
    stop = dur
  end
  if stop <= start then
    return nil, nil, "终点必须晚于起点"
  end

  return start, stop
end

local function cmd_clip()
  local path = hovered()
  if not path or path == "" then
    return notify("视频处理", "没有选中任何文件", "warn", 4)
  end
  if path:sub(1, 9) == "<dirname>" then
    return notify("视频处理", "选中的是文件夹，请选中一个视频文件", "warn", 4)
  end

  local info, perr = probe(path)
  if not info then
    return notify("视频处理", perr, "error", 10)
  end

  local answer = ask(string.format("截取哪一段？（共 %s，写成 起-止 或 起+时长）", hms(info.duration)), "")
  if not answer or answer == "" then
    return
  end

  local start, stop, rerr = parse_range(answer, info.duration)
  if not start then
    return notify("视频处理", rerr, "error", 10)
  end

  local dir, base = split_path(path)
  local out = unique_path(string.format("%s/%s_剪辑%s-%s.mp4", dir, base, hms_file(start), hms_file(stop)))

  local ok = run_ffmpeg({
    "-y", "-hide_banner", "-loglevel", "error",
    "-ss", string.format("%.3f", start),
    "-i", path,
    "-t", string.format("%.3f", stop - start),
    "-map", "0:v:0", "-map", "0:a?",
    "-c:v", "libx264", "-preset", "medium", "-crf", "20", "-pix_fmt", "yuv420p",
    "-c:a", "aac", "-b:a", "192k", "-ac", "2",
    "-sn", "-dn", "-map_metadata", "0", "-movflags", "+faststart",
    out,
  }, "截取")
  if not ok then
    return
  end

  ya.emit("refresh", {})
  notify("视频处理",
    string.format("截取完成：%s\n%s → %s（%.1f MB）", basename(out), hms(start), hms(stop), file_size(out) / 1048576),
    "info", 12)
end

return {
  entry = function(_, job)
    local action = job.args and job.args[1]
    if action == "compress" then
      return cmd_compress()
    elseif action == "clip" then
      return cmd_clip()
    end
    notify("视频处理", "未知操作：" .. tostring(action), "error", 5)
  end,
}
