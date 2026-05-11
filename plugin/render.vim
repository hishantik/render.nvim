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
	" Port range: 13378 to 65535 (stay below max port number)
	let l:offset = 13378
	let l:max_port = 65536
	let g:render_server_port = l:offset + (getpid() % (l:max_port - l:offset))
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
	" 0 = auto-detect browser, 'cmd' = custom command
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
command! -nargs=0 RenderConfig call render#config()

function! render#config()
	let l:path = has('nvim') ? stdpath('config') . '/init.lua' : $HOME . '/.vimrc'
	if filereadable(l:path)
		execute 'edit ' . fnameescape(l:path)
	else
		echom 'Config file not found: ' . l:path
	endif
endfunction
