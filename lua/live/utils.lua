local M = {}

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

function M.get_extension(path)
	return vim.fn.fnamemodify(path, ":e")
end

function M.debounce(fn, delay)
	local timer = nil

	return function(...)
		local args = { ... }

		if timer then
			timer:stop()
			timer:close()
		end

		timer = vim.uv.new_timer()

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

return M
