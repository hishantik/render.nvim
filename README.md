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
- **Debounced Updates** — Efficient bandwidth usage with 100ms debounce

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

### Using lazy.nvim

```lua
{
  'hishantik/render.nvim',
  ft = { 'html', 'css', 'javascript', 'typescript', 'tsx' },
}
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
| `:RenderConfigure {type} {rules}` | Configure validation rules |
| `:RenderConfig` | Open config file (init.vim/init.lua) |

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

" Stop when finished
:RenderStop
```

## Using TypeScript Files

TypeScript (.ts) and TSX (.tsx) files are automatically supported:

1. Open a TypeScript file: `:e component.tsx`
2. Run `:Render` as usual
3. JavaScript changes are reflected in real-time

## Using Mobile Preview

Test your designs on mobile devices connected to the same network.

### Setup for Local Network Access

```vim
" In init.vim (Vim)
let g:render_server_allow_remote_connections = 1
```

```lua
-- In init.lua (Neovim)
vim.g.render_server_allow_remote_connections = 1
```

### Generate QR Code

```vim
" Start the server first
:Render

" Open QR code page in browser
:RenderMobile
```

The QR code will automatically use your LAN IP (e.g., `http://192.168.1.100:13378/qr`) when remote connections are enabled. Scan with your phone to preview.

## Custom Error Handlers

Configure validation rules for HTML and CSS to match your project's standards.

### Configure HTML Rules

```vim
" In init.vim
let g:render_html_rules = {
    \ 'tag-pair': v:true,
    \ 'attr-lowercase': v:true,
    \ 'doctype-first': v:false
\}

" Or use RenderConfigure command
:RenderConfigure html {'tag-pair': v:true, 'doctype-first': v:false}
```

```lua
-- In init.lua
vim.g.render_html_rules = {
    ['tag-pair'] = true,
    ['attr-lowercase'] = true,
    ['doctype-first'] = false
}
```

### Configure CSS Rules

```vim
" Enable specific CSSLint rules
let g:render_csslint_rules = ['compatible-vendor-prefixes', 'box-model']
```

```lua
-- In init.lua
vim.g.render_csslint_rules = { 'compatible-vendor-prefixes', 'box-model' }
```

## WebSocket Reconnection

The plugin automatically handles connection drops with exponential backoff reconnection:

1. Connection lost → Status indicator shows "reconnecting..."
2. Exponential backoff: 1s, 2s, 4s, 8s... up to 30s max
3. Connection restored → Status indicator disappears

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
| `g:render_server_allow_remote_connections` | `0` | Allow mobile/network access |

### Quick Configuration

Use `:RenderConfig` to open your config file quickly:

```vim
:RenderConfig
```

### Complete Configuration Example (Vim)

```vim
" Use Chrome instead of default browser
let g:render_browser_command = 'google-chrome'

" Don't auto-open browser
let g:render_auto_start_browser = 0

" Reload page on HTML save
let g:render_refresh_on_save = 1

" Allow mobile device access
let g:render_server_allow_remote_connections = 1

" Use specific port
let g:render_server_port = 8080

" Custom HTML validation rules
let g:render_html_rules = {
    \ 'tag-pair': v:true,
    \ 'doctype-first': v:false
\}

" Custom CSSLint rules
let g:render_csslint_rules = ['compatible-vendor-prefixes']
```

### Complete Configuration Example (Neovim/Lua)

```lua
-- In init.lua
vim.g.render_browser_command = 'google-chrome'
vim.g.render_auto_start_browser = 0
vim.g.render_refresh_on_save = 1
vim.g.render_server_allow_remote_connections = 1
vim.g.render_server_port = 8080

vim.g.render_html_rules = {
    ['tag-pair'] = true,
    ['doctype-first'] = false
}

vim.g.render_csslint_rules = { 'compatible-vendor-prefixes' }
```

## How It Works

```
Vim ──Python──> Node Server ──WebSocket──> Browser
```

1. **Server Start** — Python bridge launches Node.js server
2. **File Serving** — HTML parsed into AST, client scripts injected
3. **Change Detection** — Vim events trigger content sync (debounced 100ms)
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

### Buffer Updates

- Changes are debounced (100ms) to reduce bandwidth
- Sends full buffer after typing pause
- Prevents excessive network traffic during rapid editing

## Performance

| Operation | Latency |
|-----------|---------|
| Local round-trip | 5-20ms |
| Initial HTML parse | 50-200ms |
| Diff update | 1-5ms |
| Debounce delay | 100ms |

- Memory usage scales with open files
- Large files (>10MB) may cause delays
- Debouncing reduces bandwidth significantly

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