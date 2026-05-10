"File:        render.vim
"Version:     0.0.1
"Repository:  https://github.com/Hishantik/render.nvim
"License:     Released under the GPL V2 license

if !exists("g:render_server_log")
	let g:render_server_log = "/tmp/render_server_logfile"
endif

if !exists("g:render_server_path")
	let g:render_server_path = "http://127.0.0.1"
endif

if !exists("g:render_server_port")
	let offset = 13378
	let port_max = 65536
	let g:render_server_port = offset + (getpid() % (port_max-offset))
endif

if !exists("g:render_server_allow_remote_connections")
	let g:render_server_allow_remote_connections = 0
endif

if !exists("g:render_auto_start_server")
	let g:render_auto_start_server = 1
endif

if !exists("g:render_eval_on_save")
	let g:render_eval_on_save = 1
endif

if !exists("g:render_refresh_on_save")
	let g:render_refresh_on_save = 0
endif

if !exists("g:render_auto_start_browser")
	let g:render_auto_start_browser = 1
endif

if !exists("g:render_browser_command")
	"0 = auto (using
	"'...' = command to run
	let g:render_browser_command = 0
endif

if !exists("g:render_html_rules")
	let g:render_html_rules = {}
endif

if !exists("g:render_csslint_rules")
	let g:render_csslint_rules = []
endif

command! -nargs=0 Render call render#start()
command! -nargs=0 RenderStop  call render#stop()
command! -nargs=0 RenderReload call render#reload()
command! -nargs=* RenderEval call render#evalFile(<f-args>)
command! -nargs=0 RenderMobile call render#mobile()
command! -nargs=+ RenderConfigure call render#configure(<f-args>)
command! -nargs=0 RenderInit call render#init()

function! render#init()
	let l:plugin_path = expand('<sfile>:p:h:h')
	let l:example_file = l:plugin_path . '/render.vim.example'
	let l:config_path = has('nvim') ? stdpath('config') : split(&runtimepath, ',')[0]

	" Try common config locations
	let l:locations = [
		\ expand('~/.config/nvim/'),
		\ expand('~/.vim/'),
		\ l:config_path
	\]

	for l:dir in l:locations
		if isdirectory(l:dir) && filewritable(l:dir) == 2
			let l:dest = l:dir . 'render.vim.example'
			call writefile(readfile(l:example_file, 'b'), l:dest, 'b')
			echom 'Example config copied to: ' . l:dest
			echom 'Copy contents to your init.vim or source this file.'
			return
		endif
	endfor

	echom 'Could not find writable config directory.'
	echom 'Example file location: ' . l:example_file
endfunction
