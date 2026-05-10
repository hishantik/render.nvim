# render.nvim

A live preview plugin for Neovim that enables real-time editing of HTML, CSS, and JavaScript files directly in the browser.

![Python](https://img.shields.io/badge/Python-2.7%2B%2C%203.x-blue)
![Node.js](https://img.shields.io/badge/Node.js-12%2B-green)
![License](https://img.shields.io/badge/License-GPL--2.0-blue)

## Features

- **Live Preview** — See changes instantly in your browser as you edit
- **Real-time Sync** — HTML, CSS, and JavaScript changes are reflected immediately
- **Cursor Tracking** — Highlights the element under your cursor in the browser
- **CSS Selection** — Click browser elements to jump to corresponding CSS rules
- **Error Display** — Shows HTML/CSS validation errors inline
- **WebSocket Communication** — Fast, persistent connection between editor and browser
- **Diff-based Updates** — Efficient DOM updates using minimal operations
- **TypeScript Support** — Live preview for .ts and .tsx files
- **WebSocket Reconnection** — Automatic reconnection with visual status indicator
- **Custom Error Handlers** — Configurable HTML/CSS validation rules
- **Mobile Preview** — QR code generation for testing on mobile devices

## Tech Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                         Architecture                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │  Neovim  │ -> │  Python  │ -> │  Node.js │ -> │  Browser │  │
│  │ (Vimscript)  │   │ (Bridge) │    │ (Server) │    │ (Client) │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                         Technologies                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Editor:    Vimscript / Lua                                    │
│  Bridge:    Python 2/3 (HTTP communication)                    │
│  Server:    Node.js + WebSocket                                │
│  Parsing:   htmlparser2, domhandler, postcss, csslint           │
│  Client:    Vanilla JavaScript (no dependencies)               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites

- **Neovim** or **Vim** with Python support
- **Node.js** (v12 or higher)
- **Python** 2.7+ or 3.x

### Using vim-plug

```vim
Plug 'hishantik/render.nvim'
```

### Using packer.nvim

```lua
use 'hishantik/render.nvim'
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/hishantik/render.nvim.git ~/.config/nvim/plugged/render.nvim

# Install Node.js dependencies
cd ~/.config/nvim/plugged/render.nvim/server
npm install
```

## Usage

### Basic Commands

| Command | Description |
|---------|-------------|
| `:Render` | Start the server and open browser |
| `:RenderStop` | Stop the server |
| `:RenderReload` | Force reload the page |
| `:RenderEval {code}` | Execute JavaScript in browser |
| `:RenderMobile` | Open QR code page for mobile preview |
| `:RenderConfigure {type} {config}` | Configure validation rules |

### Getting Started

1. Open an HTML file in Neovim
2. Run `:Render` to start the server
3. Edit your files and see changes in real-time
4. Use `:RenderStop` to shut down when done

### Example Workflow

```vim
" Open an HTML file
:e index.html

" Start live preview
:Render

" Make changes - they appear instantly in the browser
" Edit CSS, HTML, or JS and see real-time updates

" Stop when finished
:RenderStop
```

## Configuration

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `g:render_browser_command` | `0` | Browser launch command (0 = auto) |
| `g:render_auto_start_browser` | `1` | Auto-open browser on start |
| `g:render_auto_start_server` | `1` | Auto-start Node server |
| `g:render_eval_on_save` | `1` | Evaluate JS on save |
| `g:render_refresh_on_save` | `0` | Reload page on save |
| `g:render_server_port` | `pid-based` | Server port number |
| `g:render_server_path` | `http://127.0.0.1` | Server URL |
| `g:render_server_log` | `/tmp/render_server_logfile` | Server log path |
| `g:render_html_rules` | `{}` | Custom HTML validation rules |
| `g:render_csslint_rules` | `[]` | Custom CSSLint rules |

### Example Configuration

```vim
" Use Chrome instead of default browser
let g:render_browser_command = 'google-chrome'

" Don't auto-open browser
let g:render_auto_start_browser = 0

" Reload page on HTML save
let g:render_refresh_on_save = 1

" Use specific port
let g:render_server_port = 8080

" Custom HTML validation rules
let g:render_html_rules = {
	\ 'tag-pair': true,
	\ 'attr-lowercase': true,
	\ 'doctype-first': false
\}

" Custom CSSLint rules (empty = all enabled)
let g:render_csslint_rules = ['compatible-vendor-prefixes']
```

## How It Works

```
Vim ──Python──> Node Server ──WebSocket──> Browser
```

1. **Server Start** — Python bridge launches Node.js server
2. **File Serving** — HTML parsed into AST, client scripts injected
3. **Change Detection** — Vim events trigger content sync
4. **Diff Updates** — Server computes minimal DOM operations
5. **Broadcast** — Changes sent via WebSocket to browser
6. **Apply** — Client updates DOM with minimal operations

### HTML Transformation

- Parses HTML into Abstract Syntax Tree (AST)
- Assigns unique indices to elements for selection
- Injects frontend.js and frontend.css
- Diffs changes against existing AST for updates

### Cursor Sync

- Tracks cursor position via `CursorMoved` and `TextChanged`
- Converts line/column to character index
- Maps to AST element for browser highlighting

## Performance

| Operation | Latency |
|-----------|---------|
| Local round-trip | 5-20ms |
| Initial HTML parse | 50-200ms |
| Diff update | 1-5ms |

- Memory usage scales with open files
- Large files (>10MB) may cause delays
- Remote connections add network latency

## License

[GPL-2.0](LICENSE)

## Author

**Hishantik**

- GitHub: [hishantik](https://github.com/hishantik)
- Repository: [render.nvim](https://github.com/hishantik/render.nvim)

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## Acknowledgments

Originally based on [bracey.vim](https://github.com/turbio/bracey.vim) by Mason Clayton.