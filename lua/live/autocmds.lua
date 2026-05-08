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

	if path == "" then
		return
	end

	local ext = vim.fn.fnamemodify(path, ":e")

	if not allowed[ext] then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	local content = table.concat(lines, "\n")

	require("live.rpc").send({
		type = ext,
		path = path,
		content = content,
	})
end

function M.setup()
	vim.api.nvim_create_autocmd({
		"TextChanged",
		"TextChangedI",
	}, {
		group = group,

		callback = function(args)
			debounce(args.buf, function()
				send_buffer(args.buf)
			end, 120)
		end,
	})

	vim.api.nvim_create_autocmd({
		"BufWritePost",
	}, {
		group = group,

		callback = function(args)
			send_buffer(args.buf)
		end,
	})
end

return M
