local Marionette = require("webview.firefox.marionette")

local MAC_PATHS = {
    "/Applications/Firefox.app/Contents/MacOS/firefox",
    "/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox",
}

---@class webview.Firefox
---@field path string #path to firefox binary
---@field private __marionette webview.firefox.Marionette
---@field private __process? vim.SystemObj
local M = {}
M.__index = M

---Creates a new firefox marionette driver instance.
---@param opts? {path?:string}
---@return webview.Firefox
function M:new(opts)
    opts = opts or {}

    local instance = {}
    setmetatable(instance, M)

    instance.path = opts.path or "firefox"
    instance.__marionette = Marionette:new()

    -- If firefox isn't on the immediate path, try accessing it as a Mac app
    if vim.fn.executable(instance.path) == 0 then
        for _, path in ipairs(MAC_PATHS) do
            if vim.fn.executable(path) == 1 then
                instance.path = path
                break
            end
        end
    end

    return instance
end

---Returns true if firefox binary exists and is available on path.
---@return boolean
function M:exists()
    return vim.fn.executable(self.path) == 1
end

---Returns the host used to access Firefox marionette.
---@return string
function M:marionette_host()
    return self.__marionette.host
end

---Returns the port used to access Firefox marionette.
---@return integer
function M:marionette_port()
    return self.__marionette.port
end

---Starts a new headless firefox instance with marionette enabled.
---@return webview.utils.Promise
function M:start()
    -- Starts the marionette process
    self.__process = vim.system({ self.path, "--marionette", "--headless" }, { text = true })

    -- Connect to the  marionette process over TCP, and then start a new session
    return self.__marionette:connect()
end

---Kills the active firefox instance with marionette enabled.
function M:stop()
    if self.__process then
        self.__process:kill("sigkill")
    end
end

---Returns true if firefox marionette is running & connected over TCP.
---@return boolean
function M:is_connected()
    return self.__marionette:is_connected()
end

---Sends some command using marionette, returning a promise that resolves to the response.
---@param command string
---@param data? table
---@return webview.utils.Promise
function M:send(command, data)
    return self.__marionette:send(command, data)
end

return M
