local M = {}

---@class temperature.Data
---@field current_condition temperature.data.CurrentCondition[]

---@class temperature.data.CurrentCondition
---@field temp_F string # numeric, but needs to be parsed

---@param s string
---@return string
local function url_encode(s)
    s = s:gsub("\n", "\r\n")
    s = s:gsub("([^%w _%%%-%.~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    s = s:gsub(" ", "+")
    return s
end

---Retrieves temperature as an object.
---@param opts? {location?:string}
---@return temperature.Data
function M.fetch(opts)
    opts = opts or {}

    ---@type string
    local location = opts.location or vim.fn.input("Location: ")

    -- Open with our curl command accessing the temperature, returning JSON
    local results = vim.system({ "curl", "wttr.in/" .. url_encode(location) .. "?format=j1" }):wait()
    if results.code ~= 0 then
        error("failed to retrieve temperature: " .. (results.stderr or ""))
    end

    ---@type temperature.Data
    local data = vim.json.decode(results.stdout or "", { array = true, object = true })

    return data
end

---Prints the temperature for right now.
---@param opts? {location?:string}
function M.print(opts)
    opts = opts or {}
    local location = opts.location
    local temperature = M.fetch(opts)
    local cc = temperature.current_condition[1]
    local msg = ("It's currently %s°F %s"):format(
        cc.temp_F,
        location and ("in " .. location) or "for you"
    )
    vim.api.nvim_out_write("\n" .. msg .. "\n")
end
