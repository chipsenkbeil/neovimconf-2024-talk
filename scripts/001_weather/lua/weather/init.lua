local M = {}

---@class weather.Data
---@field current_condition weather.data.CurrentCondition[]

---@class weather.data.CurrentCondition
---@field FeelsLikeC string # numeric, but needs to be parsed
---@field FeelsLikeF string # numeric, but needs to be parsed
---@field temp_C string # numeric, but needs to be parsed
---@field temp_F string # numeric, but needs to be parsed

---Retrieves weather as an object.
---@param opts? {location?:string}
---@return weather.Data
function M.retrieve_weather(opts)
    opts = opts or {}

    ---@type string
    local location = opts.location or vim.fn.input("Location: ")

    -- Open with our curl command accessing the weather, returning JSON
    local results = vim.system({ "curl", "wttr.in/" .. location .. "?format=j1" }):wait()
    if results.code ~= 0 then
        error("failed to retrieve weather: " .. (results.stderr or ""))
    end

    ---@type weather.Data
    local data = vim.json.decode(results.stdout or "", { array = true, object = true })

    return data
end

---Prints the temperature for right now.
---@param opts? {location?:string}
function M.check_temperature(opts)
    local weather = M.retrieve_weather(opts)
    local cc = weather.current_condition[1]
    local msg = ("Temp %s F (feels like %s F)"):format(cc.temp_F, cc.FeelsLikeF)
    vim.api.nvim_out_write("\n" .. msg .. "\n")
end

---Shows the weather by creating a floating window and launching a terminal
---with curl to display the weather in a fancy way.
---@param opts? {location?:string}
function M.show_weather(opts)
    opts = opts or {}

    ---@type string
    local location = opts.location or vim.fn.input("Location: ")

    -- Create an immutable scratch buffer that is wiped once hidden
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    -- Create a floating window using the scratch buffer positioned in the middle
    local height = math.ceil(vim.o.lines * 0.8)  -- 80% of screen height
    local width = math.ceil(vim.o.columns * 0.8) -- 80% of screen width
    local win = vim.api.nvim_open_win(buf, true, {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = math.ceil((vim.o.lines - height) / 2),
        col = math.ceil((vim.o.columns - width) / 2),
        border = "single",
    })

    -- Change to the window that is floating to ensure termopen uses correct size
    vim.api.nvim_set_current_win(win)

    -- Open with our curl command accessing the weather
    --
    -- u = United States weather units (F)
    -- n = narrow form (day & night only)
    -- 2 = today & tomorrow only
    -- F = hide follow line
    vim.fn.termopen({ "curl", "wttr.in/" .. location .. "?un2F" }, {
        on_exit = function(_, _, _)
            vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", "<CMD>close<CR>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(buf, "n", "q", "<CMD>close<CR>", { noremap = true, silent = true })
        end
    })
end

return M
