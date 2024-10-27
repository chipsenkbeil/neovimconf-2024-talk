local Driver = require("webview.driver")
local Firefox = require("webview.firefox")
local Viewer = require("webview.viewer")

---@class WebView
---@field driver webview.Driver
---@field firefox webview.Firefox
---@field viewer webview.Viewer
local M = {}

---Creates a new webview instance.
---@return WebView
function M:new()
    local instance = {}
    setmetatable(instance, M)

    instance.firefox = Firefox:new()
    instance.viewer = Viewer:new()

    instance.driver = Driver:new({
        send = function(command, data)
            return instance.firefox:send(command, data)
        end,
    })

    return instance
end

return M
