local M = {}

local rpc = require("live.rpc")

local utils = require("live.utils")

local state = {
	connected = false,
	last_payload = nil,
}

function M.connect()
	state.connected = true

	utils.notify("live session connected")
end

function M.disconnect()
	state.connected = false

	utils.notify("live session disconnected", vim.log.levels.WARN)
end

function M.is_connected()
	return state.connected
end

function M.send(payload)
	if not state.connected then
		return
	end

	state.last_payload = payload

	rpc.send(payload)
end

function M.reload()
	M.send({
		type = "reload",
	})
end

function M.update_html(content, path)
	M.send({
		type = "html",
		content = content,
		path = path,
	})
end

function M.update_css(content, path)
	M.send({
		type = "css",
		content = content,
		path = path,
	})
end

function M.update_js(content, path)
	M.send({
		type = "js",
		content = content,
		path = path,
	})
end

function M.overlay(message)
	M.send({
		type = "overlay",
		message = message,
	})
end

function M.clear_overlay()
	M.send({
		type = "clear_overlay",
	})
end

function M.resend_last()
	if state.last_payload then
		rpc.send(state.last_payload)
	end
end

return M
