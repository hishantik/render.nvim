local M = {}

local uv = vim.uv

M.allowed_extensions = {
	html = true,
	css = true,
	js = true,
}

function M.notify(msg, level)
	vim.schedule(function()
		vim.notify("[live] " .. msg, level or vim.log.levels.INFO)
	end)
end

function M.buf_get_content(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	return table.concat(lines, "\n")
end

function M.buf_get_path(buf)
	return vim.api.nvim_buf_get_name(buf)
end

function M.get_extension(path)
	return vim.fn.fnamemodify(path, ":e")
end

function M.is_supported(path)
	local ext = M.get_extension(path)

	return M.allowed_extensions[ext]
end

function M.filetype_to_message(path)
	local ext = M.get_extension(path)

	if ext == "html" then
		return "html"
	end

	if ext == "css" then
		return "css"
	end

	if ext == "js" then
		return "js"
	end

	return nil
end

function M.debounce(fn, delay)
	local timer = nil

	return function(...)
		local args = { ... }

		if timer then
			timer:stop()
			timer:close()
		end

		timer = uv.new_timer()

		if not timer then
			return
		end

		timer:start(delay, 0, function()
			timer:stop()
			timer:close()

			timer = nil

			vim.schedule(function()
				fn(unpack(args))
			end)
		end)
	end
end

function M.safe_call(fn, ...)
	local ok, err = pcall(fn, ...)

	if not ok then
		M.notify(tostring(err), vim.log.levels.ERROR)
	end
end

return M
