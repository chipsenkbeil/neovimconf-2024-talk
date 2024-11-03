local Driver = require("webview.driver")
local Firefox = require("webview.firefox")
local Viewer = require("webview.viewer")

---@class WebView
---@field driver webview.Driver
---@field firefox webview.Firefox
---@field viewer webview.Viewer
---@field private __started boolean|"starting"
local M = {}
M.__index = M

---Creates a new webview instance.
---@return WebView
function M:new()
    local instance = {}
    setmetatable(instance, M)

    instance.firefox = Firefox:new()
    instance.viewer = Viewer:new()
    instance.__started = false

    instance.driver = Driver:new({
        send = function(command, data)
            return instance.firefox:send(command, data)
        end,
    })

    return instance
end

---Starts the webview instance, spawning firefox and connecting to marionette.
---
---If already started, this does nothing.
---@param opts? {delay?:integer}
---@return webview.utils.Promise
function M:start(opts)
    local Promise = require("webview.utils.promise")

    if self.__started == "starting" or self.__started then
        return Promise.new(function(resolve)
            resolve()
        end)
    end

    self.__started = "starting"

    opts = opts or {}
    return self.firefox:start():next(function()
        return Promise.delay(opts.delay or 500):next(function()
            return self.driver:new_session():next(function()
                self.__started = true
                return nil
            end)
        end)
    end):catch(function()
        self.__started = false
    end)
end

---Stops the webview instance.
function M:stop()
    self.__started = false
    return self.firefox:stop()
end

---Navigates to the specified url.
---@param url string
---@return webview.utils.Promise
function M:navigate(url)
    return self.driver:navigate({ url = url })
end

---Displays the current browser as a screenshot in a floating window.
---@return webview.utils.Promise<{win:integer, buf:integer}>
function M:display_screen()
    local Promise = require("webview.utils.promise")
    return self:take_screenshot():next(function(results)
        local path = results.path
        return self.viewer:view({ path = path })
    end)
end

---Takes a screenshot, saving it to the specified path (or temp), returning the path to the file.
---@param opts? {id?:string, full?:boolean, scroll?:boolean, path?:string}
---@return webview.utils.Promise<{path:string}>
function M:take_screenshot(opts)
    opts = opts or {}

    ---@diagnostic disable-next-line:param-type-mismatch
    return self.driver:take_screenshot(opts):next(function(data)
        local Promise = require("webview.utils.promise")

        return Promise.new(function(resolve, reject)
            local decoded = vim.base64.decode(data)
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
                        resolve({ path = path })
                    end)
                end)
            end)
        end)
    end)
end

return M:new()
