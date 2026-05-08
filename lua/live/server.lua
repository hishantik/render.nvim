local M = {}

local state = {
	job = nil,
	running = false,
	config = {},
}

function M.setup(config)
	state.config = config
end

function M.start()
	if state.running then
		return
	end

	local root = vim.fn.stdpath("data") .. "/lazy/render.nvim/server"

	local server_file = root .. "/index.js"

	state.job = vim.system({
		"node",
		server_file,
		"--port",
		tostring(state.config.port),
	}, {
		detach = true,
		text = true,
	}, function(obj)
		state.running = false

		if obj.code ~= 0 then
			vim.schedule(function()
				vim.notify("Live server exited: " .. obj.stderr, vim.log.levels.ERROR)
			end)
		end
	end)

	state.running = true

	vim.notify("Live server started")
end

function M.stop()
	if not state.job then
		return
	end

	pcall(function()
		state.job:kill(15)
	end)

	state.running = false
	state.job = nil

	vim.notify("Live server stopped")
end

function M.restart()
	M.stop()

	vim.defer_fn(function()
		M.start()
	end, 100)
end

function M.is_running()
	return state.running
end

return M
