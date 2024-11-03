local BIN = "sl"
local BUFNAME = "sapling://smartlog"

local M = {}

---Update working copy to the specified revision (commit).
---@param rev string
---@param cb? fun(err:string|nil) #optional callback to run command async, otherwise blocks
function M.goto_rev(rev, cb)
    vim.validate({
        rev = { rev, "string" },
        cb = { cb, "function", true },
    })

    ---@type fun(out:vim.SystemCompleted)|nil
    local on_exit
    if cb then
        ---@param out vim.SystemCompleted
        on_exit = function(out)
            ---@type string|nil
            local err

            if out.code ~= 0 then
                err = out.stderr or ("failed with exit code " .. tostring(out.code))
            end

            cb(err)
        end
    end

    local obj = vim.system({ BIN, "goto", rev }, { text = true }, on_exit)

    if not on_exit then
        return obj:wait()
    end
end

---Retrieve the smartlog as a text blob.
---
---If provided a callback, runs asynchronously, otherwise blocks.
---@param cb? fun(err:string|nil, output:string|nil)
---@return string|nil err, string|nil output
function M.smartlog(cb)
    vim.validate({
        cb = { cb, "function", true },
    })

    ---@param out vim.SystemCompleted
    ---@return string|nil err, string|nil output
    local function build_out(out)
        ---@type string|nil, string|nil
        local err, output

        if out.code ~= 0 then
            err = out.stderr or ("failed with exit code " .. tostring(out.code))
        else
            output = out.stdout or ""
        end

        return err, output
    end

    ---@type fun(out:vim.SystemCompleted)|nil
    local on_exit
    if cb then
        ---@param out vim.SystemCompleted
        on_exit = function(out)
            local err, output = build_out(out)
            cb(err, output)
        end
    end

    -- NOTE: We use a specific template to keep things consistent!
    local obj = vim.system({
        BIN, "smartlog",
        "--template", "{node|short} {desc|firstline}\n",
    }, { text = true }, on_exit)

    if not on_exit then
        local err, output = build_out(obj:wait())
        return err, output
    end
end

-- Function to toggle the terminal buffer on the left side
function M.show()
    ---@param buf integer
    ---@param lines string[]
    ---@param cb? fun()
    local function set_buf_lines(buf, lines, cb)
        vim.schedule(function()
            vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
            if cb then cb() end
        end)
    end

    ---Refreshes the buffer asynchronously.
    ---@param buf integer
    local function refresh_buffer(buf)
        -- Clear the buffer and indicate it is loading
        set_buf_lines(buf, { "Loading..." }, function()
            -- Trigger retrieving the smartlog to populate the buffer
            M.smartlog(function(err, output)
                assert(not err, err)
                local lines = vim.split(output or "", "\n")
                set_buf_lines(buf, lines)
            end)
        end)
    end

    ---Retrieves the line at the cursor for the specified window.
    ---@param win integer #window handle, or 0 for current window
    local function line_at_cursor(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local line = vim.api.nvim_win_get_cursor(win)[1] - 1
        return vim.api.nvim_buf_get_lines(buf, line, line + 1, false)[1]
    end

    -- Check if the buffer for sapling's smartlog is already open
    local buf = vim.fn.bufnr(BUFNAME)

    if buf ~= -1 then -- If buffer exists
        -- Check if it's currently visible in a window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf then
                -- If open, close the window
                vim.api.nvim_win_close(win, true)
                return
            end
        end
    else
        -- Create a new buffer if it doesn't exist
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, BUFNAME)

        -- Make buffer readonly
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

        -- Configure buffer-specific keybindings to reload and goto
        vim.keymap.set("n", "r", function() refresh_buffer(buf) end, { buffer = buf })
        vim.keymap.set("n", "<CR>", function()
            -- NOTE: We assume at the point of this callback that the
            --       current window is for our buffer
            local line = line_at_cursor(0)

            -- Figure out if we have a hash on the line, and what it would be
            --
            -- Each commit is preceded by o, x, or @ and some space
            local hash = string.match(line, "[xo@]%s+([%w]+)%s+")

            if hash then
                set_buf_lines(buf, { "Goto " .. hash }, function()
                    M.goto_rev(hash, function(err)
                        assert(not err, err)
                        refresh_buffer(buf)
                    end)
                end)
            end
        end, { buffer = buf })

        -- Trigger a manual refresh
        refresh_buffer(buf)
    end

    -- Open the buffer in a left vertical split
    vim.cmd("leftabove vnew")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)

    -- Set the window width for the left split
    vim.api.nvim_win_set_width(win, 40)
end

return M
