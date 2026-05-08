local M = {}

local preview = require("live.preview")

local websocket = require("live.websocket")

M.config = {
	port = 8080,
	host = "127.0.0.1",

	auto_start = true,
	open_browser = true,

	debounce = 150,

	browser_command = nil,

	logging = false,
}

local function create_commands()
	vim.api.nvim_create_user_command("LiveStart", function()
		preview.start()
	end, {})

	vim.api.nvim_create_user_command("LiveStop", function()
		preview.stop()
	end, {})

	vim.api.nvim_create_user_command("LiveToggle", function()
		preview.toggle()
	end, {})

	vim.api.nvim_create_user_command("LiveReload", function()
		websocket.reload()
	end, {})

	vim.api.nvim_create_user_command("LiveOpen", function()
		preview.open()
	end, {})

	vim.api.nvim_create_user_command("LiveRestart", function()
		preview.restart()
	end, {})
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	preview.setup(M.config)

	create_commands()

	if M.config.auto_start then
		vim.schedule(function()
			preview.start()
		end)
	end
end

return M
