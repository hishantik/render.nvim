local M = {}

function M.setup(config)
	M.host = config.host
	M.port = config.port
end

function M.send(data)
	local url = ("http://%s:%d/__live"):format(M.host, M.port)
	local json = vim.json.encode(data)

	local ok, err = pcall(function()
		if vim.http then
			vim.http.request({
				url = url,
				method = "POST",
				headers = {
					["Content-Type"] = "application/json",
				},
				body = json,
			})
		else
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
			})
		end
	end)

	if not ok then
		vim.schedule(function()
			vim.notify("[live] rpc failed: " .. tostring(err), vim.log.levels.ERROR)
		end)
	end
end

return M
