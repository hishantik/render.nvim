if vim.g.loaded_live then
	return
end

vim.g.loaded_live = 1

if vim.g.live_auto_setup ~= false then
	require("live").setup()
end
