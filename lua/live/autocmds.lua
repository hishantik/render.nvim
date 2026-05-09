local M = {}

local group = vim.api.nvim_create_augroup("LivePreview", { clear = true })

local allowed = {
	html = true,
	css = true,
	js = true,
}

local timers = {}

local function debounce(buf, fn, delay)
	if timers[buf] then
		timers[buf]:stop()
		timers[buf]:close()
	end

	local timer = vim.uv.new_timer()

	if not timer then
		return
	end

	timers[buf] = timer

	timer:start(delay, 0, function()
		vim.schedule(fn)
	end)
end

local function send_buffer(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  print("[live] send_buffer called, path:", path)

  if path == "" then
    print("[live] empty path, skipping")
    return
  end

  local ext = vim.fn.fnamemodify(path, ":e")
  print("[live] extension:", ext)

  if not allowed[ext] then
    print("[live] extension not in allowed list, skipping")
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local content = table.concat(lines, "\n")
  print("[live] sending content, length:", #content)

  require("live.rpc").send({
    type = ext,
    path = path,
    content = content,
  })
end

function M.setup()
  print("[live] setting up autocmds")

  vim.api.nvim_create_autocmd({
    "TextChanged",
    "TextChangedI",
    "BufWritePost",
  }, {
    group = group,
    callback = function(args)
      print("[live] autocmd triggered for buf:", args.buf)
      send_buffer(args.buf)
    end,
  })

  print("[live] autocmds setup complete")
end

return M