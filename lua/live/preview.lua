local M = {}

local utils = require("live.utils")

local state = {
  running = false,
  port = 8080,
  host = "127.0.0.1",
  root = nil,
  script_path = nil,
  server_job = nil,
}

local function server_url()
  return ("http://%s:%d"):format(state.host, state.port)
end

function M.is_running()
  return state.running
end

function M.start()
  if state.running then
    utils.notify("server already running")
    return
  end

  state.root = vim.fn.getcwd()

  -- Detect script path: prefer lazy install, fall back to plugin dir
  local data_path = vim.fn.stdpath("data")
  local lazy_path = data_path .. "/lazy/render.nvim/server/index.js"
  local plugin_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h:h")

  if vim.fn.filereadable(lazy_path) == 1 then
    state.script_path = lazy_path
  else
    state.script_path = plugin_path .. "/server/index.js"
  end

  -- Start server using vim.system (detached)
  local cmd = {"node", state.script_path, "--root", state.root, "--port", tostring(state.port)}
  print("[live] starting server:", vim.fn.join(cmd, " "))

  state.server_job = vim.system(cmd, {detach = true}, function(obj)
    if obj.code ~= 0 and obj.code ~= -1 then
      vim.schedule(function()
        vim.notify("[live] server error: " .. (obj.stderr or "unknown"), vim.log.levels.ERROR)
      end)
    end
  end)

  state.running = true
  utils.notify("live preview started at " .. server_url())
end

function M.stop()
  if not state.running then
    return
  end

  if state.server_job then
    pcall(function()
      state.server_job:kill(15)  -- SIGTERM
    end)
    state.server_job = nil
  end

  state.running = false
  utils.notify("live preview stopped")
end

function M.restart()
  M.stop()
  vim.defer_fn(function()
    M.start()
  end, 200)
end

function M.open()
  local url = server_url()

  local opener
  if vim.fn.has("mac") == 1 then
    opener = "open"
  elseif vim.fn.has("unix") == 1 then
    opener = "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    opener = "start"
  end

  if not opener then
    utils.notify("unsupported platform", vim.log.levels.ERROR)
    return
  end

  vim.fn.system({ opener, url })
  utils.notify("opened browser")
end

function M.toggle()
  if state.running then
    M.stop()
  else
    M.start()
  end
end

function M.setup(opts)
  opts = opts or {}
  state.port = opts.port or state.port
  state.host = opts.host or state.host
end

return M