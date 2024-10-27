local Emitter = require("webview.utils.emitter")
local Promise = require("webview.utils.promise")

local MARIONETTE_HOST = "127.0.0.1"
local MARIONETTE_PORT = 2828

---@class webview.firefox.Marionette
---@field host string
---@field port integer
---@field private __connected boolean
---@field private __emitter webview.utils.Emitter
---@field private __msg_cnt integer
local M = {}
M.__index = M

---Creates a new, unconnected marionette TCP instance.
---@param opts? {host?:string, port?:integer}
---@return webview.firefox.Marionette
function M:new(opts)
    opts = opts or {}

    local instance = {}
    setmetatable(instance, M)

    instance.host = opts.host or MARIONETTE_HOST
    instance.port = opts.port or MARIONETTE_PORT
    instance.__connected = false
    instance.__emitter = Emitter:new()
    instance.__msg_cnt = 0

    return instance
end

---Returns true if connected to the marionette TCP port.
---@return boolean
function M:is_connected()
    return self.__connected
end

---Performs the connection to the marionette instance.
---@return webview.utils.Promise
function M:connect()
    return Promise.new(function(resolve, reject)
        local tcp = vim.uv.new_tcp()
        tcp:connect(self.host, self.port, function(err)
            if err then
                return reject(err)
            end

            self.__connected = true
            resolve()

            local emitter = self.__emitter
            tcp:read_start(function(err, data)
                if err then
                    emitter:emit("error", err)
                    return
                end

                -- If no data, this is EOF for connection and we terminate
                if not data then
                    emitter:emit("close")
                    return
                end

                emitter:emit("data", data)
            end)

            ---Internal cache of data received from TCP stream
            ---@type string
            local data = ""

            ---@param chunk string
            emitter:on("data", function(chunk)
                -- Update our cache to contain the chunk
                data = data .. chunk

                -- Check if we have a number, :, and X bytes available
                local _, _, scnt, rest = string.find(data, "(%d+):(.+)")
                local cnt = tonumber(scnt)
                if type(cnt) == "number" and string.len(rest) >= cnt then
                    local msg = string.sub(rest, 1, cnt)
                    data = string.sub(rest, cnt + 1)

                    ---@type {[1]:1, [2]:integer, [3]:table|nil, [4]:any|nil}
                    local decoded = vim.json.decode(msg, {
                        luanil = { array = true, object = true },
                    })

                    if decoded[1] == 1 then
                        emitter:emit("recv", decoded[2], decoded[3], decoded[4])
                    end
                end
            end)

            emitter:on("send", function(data)
                tcp:write(data)
            end)

            emitter:once("close", function()
                self.__connected = false
                tcp:read_stop()
                tcp:close()
            end)
        end)
    end)
end

---@param command string
---@param data? table
---@return webview.utils.Promise<{[1]:string, [2]:any}>
function M:send(command, data)
    -- Increment message count as marionette does it sequentially
    self.__msg_cnt = self.__msg_cnt + 1

    -- Use new count for our id (should start with 1, then 2, ...)
    local msg_id = self.__msg_cnt

    -- Ensure that our data is in a proper format (no lists, use null for nil)
    if type(data) == "nil" then
        data = vim.NIL
    elseif type(data) == "table" and vim.tbl_isempty(data) then
        data = vim.empty_dict()
    end

    -- Build our message, which is a four-item list
    -- Item 1 = 0 for request, 1 for response
    -- Item 2 = msg id
    -- Item 3 = command
    -- Item 4 = optional JSON encoded parameters
    local msg = { 0, msg_id, command, data }

    -- Encode our message, which is <size in bytes>:<msg>
    local encoded = vim.json.encode(msg)
    encoded = string.len(encoded) .. ":" .. encoded

    local emitter = self.__emitter
    return Promise.new(function(resolve, reject)
        ---@param id integer
        ---@param err? {error:string, message:string, stacktrace:string}
        ---@param result? any
        local function on_recv(id, err, result)
            if id == msg_id then
                if err then
                    reject(err)
                elseif result then
                    resolve(result)
                else
                    reject({
                        error = "no response",
                        message = "No response payload received from the ",
                        stacktrace = "",
                    })
                end

                emitter:off("recv", on_recv)
            end
        end

        -- Listen for received messages until we get back a response
        emitter:on("recv", on_recv)

        -- Queue up our message
        emitter:emit("send", encoded)
    end)
end

return M
