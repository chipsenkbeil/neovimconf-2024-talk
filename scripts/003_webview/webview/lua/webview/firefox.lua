local Marionette = require("webview.firefox.marionette")
local Promise = require("webview.utils.promise")

local MAC_PATHS = {
    "/Applications/Firefox.app/Contents/MacOS/firefox",
    "/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox",
}

---List of all processes to ensure that they get terminated on shutdown.
---@type vim.SystemObj[]
local PROCESSES = {}

---@class webview.Firefox
---@field path string #path to firefox binary
---@field private __marionette webview.firefox.Marionette
---@field private __port integer
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
    instance.__port = 2828

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
    return self.__port
end

---Generate a firefox profile and modify the prefs.js to use a custom port,
---returning a promise of the path to the profile directory.
---@param opts {path:string, name:string, port?:integer}
---@return webview.utils.Promise<string>
function M:make_profile(opts)
    local cwd = opts.path
    local profile_dir = vim.fs.joinpath(cwd, opts.name)

    local process = vim.system({
        self.path,
        "--headless",     -- Don't make it visible
        "--new-instance", -- Don't open a new window, make it clean
        "--profile",      -- Specify a new profile
        opts.name,
    }, { text = true, cwd = cwd })

    -- Trigger terminating firefox without a hard kill
    process:kill("sigint")

    -- Wait for firefox to terminate
    process:wait()

    -- Load up the preferences file and add a line to set the port
    local path = vim.fs.joinpath(profile_dir, "prefs.js")
    return Promise.new(function(resolve, reject)
        vim.uv.fs_open(path, "a", 438, function(err, fd)
            if err then
                return reject(err)
            end

            if not fd then
                return reject("no error, but missing file descriptor")
            end

            local port = opts.port or 2828
            local data = table.concat({
                "",
                "user_pref(\"marionette.port\", " .. tostring(port) .. ");",
                "",
            }, "\n")

            vim.uv.fs_write(fd, data, function(err)
                if err then
                    return reject(err)
                end

                vim.uv.fs_close(fd, function()
                    resolve()
                end)
            end)
        end)
    end)
end

---Starts a new headless firefox instance with marionette enabled.
---
---Takes an optional delay to wait between starting firefox and connecting.
---Defaults to 500 milliseconds.
---@param opts? {delay?:integer}
---@return webview.utils.Promise
function M:start(opts)
    opts = opts or {}

    -- Starts the marionette process
    local proc = vim.system({
        self.path,
        "--marionette",   -- Enable remote controls
        "--headless",     -- Don't make it visible
        "--new-instance", -- Don't open a new window, make it clean
    }, { text = true })

    -- Register the process to be cleaned up
    table.insert(PROCESSES, proc)
    self.__process = proc

    -- Connect to the  marionette process over TCP, and then start a new session
    return Promise.delay(opts.delay or 500):next(function()
        return self.__marionette:connect()
    end)
end

---Kills the active firefox instance with marionette enabled.
function M:stop()
    if self.__process then
        self.__process:kill("sigkill")
        self.__process = nil
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

-- Register a global callback to kill all dangling firefox processes
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        for _, proc in ipairs(PROCESSES) do
            proc:kill("sigkill")
        end
    end,
})

return M
