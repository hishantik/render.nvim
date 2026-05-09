local M = {}

function M.setup(config)
	M.host = config.host
	M.port = config.port
end

function M.send(data)
	local url = ("http://%s:%d/__live"):format(M.host, M.port)

	vim.http.request({
		url = url,
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
		},
		body = vim.json.encode(data),
	})
end

return M
