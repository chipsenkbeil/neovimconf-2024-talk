local Driver = require("webview.driver")
local Firefox = require("webview.firefox")
local Viewer = require("webview.viewer")

---@class WebView
---@field driver webview.Driver
---@field firefox webview.Firefox
---@field viewer webview.Viewer
local M = {}
M.__index = M

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

---Starts the webview instance, spawning firefox and connecting to marionette.
---@return webview.utils.Promise
function M:start()
    local Promise = require("webview.utils.promise")
    return self.firefox:start():next(function()
        return Promise.delay(500):next(function()
            return self.driver:new_session()
        end)
    end)
end

---Stops the webview instance.
function M:stop()
    return self.firefox:stop()
end

---Navigates to the specified url.
---@param url string
---@return webview.utils.Promise
function M:navigate(url)
    return self.driver:navigate({ url = url })
end

---Takes a screenshot, saving it to the specified path (or temp), returning the path to the file.
---@param opts? {id?:string, full?:boolean, scroll?:boolean, path?:string}
---@return webview.utils.Promise<{path:string}>
function M:take_screenshot(opts)
    opts = opts or {}

    ---@diagnostic disable-next-line:param-type-mismatch
    return self.driver:take_screenshot(opts):next(function(data)
        local base64 = require("webview.utils.base64")
        local Promise = require("webview.utils.promise")

        return Promise.new(function(resolve, reject)
            local decoded = base64.decode(data)
            local path = opts.path or (vim.fn.tempname() .. "_screenshot.png")

            -- NOTE: 438 is 0o666
            vim.uv.fs_open(path, "w", 438, function(err, fd)
                if err then
                    return reject(err)
                end

                if not fd then
                    return reject("no error, but missing file descriptor")
                end

                vim.uv.fs_write(fd, decoded, function(err)
                    if err then
                        return reject(err)
                    end

                    vim.uv.fs_close(fd, function()
                        resolve(path)
                    end)
                end)
            end)
        end)
    end)
end

return M
