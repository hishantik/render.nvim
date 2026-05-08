local M = {}

local uv = vim.uv

local utils = require("live.utils")

local autocmds = require("live.autocmds")

local websocket = require("live.websocket")

local state = {
	job = nil,
	running = false,
	port = 8080,
	host = "127.0.0.1",
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

	local server = vim.fn.stdpath("data") .. "/lazy/live.nvim/server/index.js"

	local cmd = {
		"node",
		server,
	}

	state.job = vim.system(cmd, {
		detach = true,
	}, function(obj)
		if obj.code ~= 0 then
			utils.notify(obj.stderr, vim.log.levels.ERROR)
		end
	end)

	state.running = true

	websocket.connect()

	autocmds.setup()

	utils.notify("live preview started")
end

function M.stop()
	if not state.running then
		return
	end

	if state.job then
		pcall(function()
			state.job:kill(15)
		end)
	end

	websocket.disconnect()

	state.job = nil
	state.running = false

	utils.notify("live preview stopped")
end

function M.restart()
	M.stop()

	vim.defer_fn(function()
		M.start()
	end, 100)
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

	vim.system({
		opener,
		url,
	})

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
