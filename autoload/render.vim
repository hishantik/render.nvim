if !has('python') && !has('python3')
	echo 'It looks like your vim does not have python support. render depends on python to run!'
	echo 'Make sure your vim has python2 or python3 support and try again.'
	finish
endif

let s:plugin_path = fnamemodify(expand('<sfile>:p:h:h'), ':p:h')
let s:script_path = s:plugin_path.'/script/render.py'

function! render#start()
	if has('python3')
		execute 'py3file '.fnameescape(s:script_path)
	elseif has('python')
		execute 'pyfile '.fnameescape(s:script_path)
	endif

	if g:render_auto_start_server
		call render#startServer()
	endif

	call render#setupHandlers()

	"TODO: find a better way to do this than sleeping
	sleep 1000m
	call render#setVars()
	call render#setFile()
	call render#configure('html', {})
	call render#configure('css', {})

	if g:render_auto_start_browser
		call render#startBrowser(g:render_server_path.':'.g:render_server_port)
	endif
endfunction

function! render#startBrowser(url)
	if type(g:render_browser_command) == type(0)
		if has("unix")
			if system("uname -s") =~ "Darwin"
				call system('open '.shellescape(a:url).' &')
			elseif executable('termux-open')
				call system('termux-open '.shellescape(a:url))
			else
				call system('xdg-open '.shellescape(a:url).' &')
			endif
		endif
	else
		call system(g:render_browser_command.' '.a:url.' &')
	endif
endfunction

function! render#startServer()
	if has('python3')
		python3 start_server()
	elseif has('python')
		python start_server()
	endif
endfunction

function! render#stopServer()
	if has('python3')
		python3 stop_server()
	elseif has('python')
		python stop_server()
	endif
endfunction

function! render#setupHandlers()
	autocmd CursorMoved,CursorMovedI *.html,*.css,*.ts,*.tsx call render#setCursor()
	autocmd TextChanged,TextChangedI *.html,*.css,*.ts,*.tsx call render#bufferChange()
	autocmd BufEnter * call render#setFile()
	if g:render_eval_on_save
		autocmd BufWritePost *.js,*.ts,*.tsx call render#evalFile()
	endif
	if g:render_refresh_on_save
		autocmd BufWritePost *.html call render#reload()
	endif
	autocmd VimLeave * call render#stop()
endfunction

function! render#stop()
	call render#stopServer()
endfunction

function! render#sendCurrentBuffer()
	let contents = join(getline(1, '$'), "\n")
	call render#sendCommand('b:'.len(contents).':'.contents)
endfunction

function! render#evalFile(...)
	if a:0
		let content = join(a:000, ' ')
		call render#sendCommand('e:'.len(content).':'.content)
	else
		let contents = join(getline(1, '$'), "\n")
		call render#sendCommand('e:'.len(contents).':'.contents)
	endif
endfunction

function! render#reload()
	let path = expand('%')
	call render#sendCommand('r:'.len(path).':'.path)
endfunction

function! render#setFile()
	let l:path = expand('%:p')
	let l:bufname = bufname('%')
	let l:bufnum = bufnr('%')
	let l:contents = join(getline(1, '$'), "\n")

	" Format: f:bufnum_len:bufnum:name_len:name:path_len:path:ft_len:ft:b:content_len:content
	let l:header = printf('f:%d:%s:%d:%s:%d:%s:%d:%s',
		\ len(l:bufnum), l:bufnum,
		\ len(l:bufname), l:bufname,
		\ len(l:path), l:path,
		\ len(&filetype), &filetype)
	call render#sendCommand(l:header.'b:'.len(l:contents).':'.l:contents)
endfunction

function! render#setVars()
	let cwd = getcwd()
	call render#sendCommand('v:'.len(cwd).':'.cwd)
endfunction

let s:buffer_timer = 0

function! render#bufferChange()
	" Debounce: cancel previous timer and create new one
	" Wait 100ms after last keystroke before sending
	if s:buffer_timer > 0
		call timer_stop(s:buffer_timer)
	endif
	let s:buffer_timer = timer_start(100, function('s:sendBufferDeferred'))
endfunction

function! s:sendBufferDeferred(timer)
	call render#sendCurrentBuffer()
	let s:buffer_timer = 0
endfunction

function! render#setCursor()
	let line = line('.')
	let column = col('.')
	call render#sendCommand('p:'.len(line).':'.line.':'.len(column).':'.column)
endfunction

function! render#sendCommand(msg)
	if has('python3')
		python3 send(vim.eval("a:msg"))
	elseif has('python')
		python send(vim.eval("a:msg"))
	endif
endfunction

function! render#configure(typeArg, config)
	let l:rules = a:typeArg == 'html' ? g:render_html_rules : g:render_csslint_rules
	let l:json_config = json_encode({
		\ 'rules': l:rules,
		\ 'customValidators': a:typeArg == 'css' ? [] : []
	\})
	call render#sendCommand('c:'.len(a:typeArg).':'.a:typeArg.':'.len(l:json_config).':'.l:json_config)
endfunction

function! render#mobile()
	let l:url = g:render_server_path.':'.g:render_server_port.'/qr'

	" When remote connections enabled, use detected LAN IP instead of 127.0.0.1
	if g:render_server_allow_remote_connections
		let l:local_ip = s:get_local_ip()
		if !empty(l:local_ip)
			let l:url = 'http://'.l:local_ip.':'.g:render_server_port.'/qr'
		endif
	endif

	if executable('termux-open')
		call system('termux-open '.shellescape(l:url))
	elseif has("unix")
		call system('xdg-open '.shellescape(l:url).' &')
	endif
endfunction

function! s:get_local_ip() abort
	if has("unix")
		" Try `ip addr show` first (works on Termux where hostname -I doesn't exist)
		let l:output = system('ip addr show 2>/dev/null | grep "inet "')
		if v:shell_error == 0 && !empty(l:output)
			let l:lines = split(l:output, '\n')
			for l:line in l:lines
				" Extract IP from "inet 192.168.1.96/24 brd 192.168.1.255"
				let l:match = matchlist(l:line, 'inet\s\+\(\d\+\.\d\+\.\d\+\.\d\+\)')
				if !empty(l:match)
					let l:ip = l:match[1]
					" Skip loopback
					if l:ip !=# '127.0.0.1'
						return l:ip
					endif
				endif
			endfor
		endif

		" Try hostname -I (not available on Termux, but works on standard Linux)
		let l:output = system('hostname -I 2>/dev/null')
		if v:shell_error == 0 && !empty(l:output)
			let l:ips = split(l:output)
			for l:ip in l:ips
				if l:ip =~ '^\d\{1,3}\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}$'
							\ && l:ip !=# '127.0.0.0' && l:ip !=# '127.0.0.1'
							\ && l:ip !=# '0.0.0.0'
					return l:ip
				endif
			endfor
		endif

		" Fallback: use ip route get (also works on Termux)
		let l:output = system('ip route get 1 2>/dev/null')
		if v:shell_error == 0 && !empty(l:output)
			let l:match = matchlist(l:output, 'src\s\+\(\d\+\.\d\+\.\d\+\.\d\+\)')
			if !empty(l:match)
				return l:match[1]
			endif
		endif
	endif
	return ''
endfunction
