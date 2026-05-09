local M = {}

-- Store config for use in send
local state_host = "127.0.0.1"
local state_port = 8080

function M.setup(config)
  if config then
    state_host = config.host or state_host
    state_port = config.port or state_port
  end
end

function M.send(data)
  if vim.fn.has("python3") == 1 then
    local json = vim.json.encode(data)
    local tmpfile = "/tmp/live_rpc_" .. vim.fn.getpid() .. ".json"
    vim.fn.writefile({json}, tmpfile)

    -- Use a simpler approach: write Python to temp file and execute
    local pyfile = "/tmp/live_rpc_send_" .. vim.fn.getpid() .. ".py"
    local pycode = string.format([[
import urllib.request
import json

try:
    with open('%s') as f:
        data = json.load(f)
    req = urllib.request.Request(
        'http://%s:%d/__live',
        data=json.dumps(data).encode('utf-8'),
        headers={'Content-Type': 'application/json'},
        method='POST'
    )
    urllib.request.urlopen(req, timeout=2)
except Exception as e:
    print('[live] rpc error:', e)
]], tmpfile, state_host, state_port)

    vim.fn.writefile(vim.split(pycode, "\n"), pyfile)
    vim.fn.system({"python3", pyfile})
    vim.fn.delete(tmpfile)
    vim.fn.delete(pyfile)
  else
    vim.notify("[live] python3 required", vim.log.levels.ERROR)
  end
end

return M