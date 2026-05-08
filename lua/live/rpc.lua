local M = {}

local config = {
	host = "127.0.0.1",
	port = 8080,
}

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.send(data)
	local json = vim.json.encode(data)

	local url = ("http://%s:%d/__live"):format(config.host, config.port)

	vim.system({
		"curl",
		"-s",
		"-X",
		"POST",
		"-H",
		"Content-Type: application/json",
		"-d",
		json,
		url,
	}, {
		text = true,
	}, function(obj)
		if obj.code ~= 0 then
			vim.schedule(function()
				vim.notify("[live] rpc failed", vim.log.levels.ERROR)
			end)
		end
	end)
end

return M
