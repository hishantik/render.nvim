local M = {}

local rpc = require("live.rpc")

local state = {
	connected = false,
}

function M.connect()
	state.connected = true
end

function M.disconnect()
	state.connected = false
end

function M.is_connected()
	return state.connected
end

function M.reload()
	rpc.send({
		type = "reload",
	})
end

return M
