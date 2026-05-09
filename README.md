# render.nvim

Realtime live preview server for Neovim web development.

## Features

- Realtime HTML, CSS, and JavaScript preview in browser
- Instant updates on file changes (debounced)
- DOM patching for HTML changes (no full reload)
- CSS cache-busting for stylesheet updates
- WebSocket-based communication

## Installation

```lua
-- lazy.nvim
{ "hishantik/render.nvim" }
```

## Usage

```vim
:LiveStart    " Start server and open browser
:LiveStop     " Stop server
:LiveToggle   " Toggle start/stop
:LiveRestart  " Restart server
:LiveOpen     " Open browser
:LiveReload   " Force browser reload
```

## Configuration

```lua
require("live").setup({
  port = 8080,
  host = "127.0.0.1",
  auto_start = false,
})
```

## Requirements

- Neovim 0.10+ (uses `vim.http`)
- Node.js 18+
