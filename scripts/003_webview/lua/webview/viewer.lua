---@class webview.Viewer
---@field path string #path to timg binary
local M = {}
M.__index = M

---Creates a new viewer instance.
---@param opts? {path?:string}
---@return webview.Viewer
function M:new(opts)
    opts = opts or {}

    local instance = {}
    setmetatable(instance, M)

    instance.path = opts.path or "timg"

    return instance
end

---Returns true if timg binary exists and is available on path.
---@return boolean
function M:exists()
    return vim.fn.executable(self.path) == 1
end

return M
