local M = {}

---Open a floating window used to display top.
---@param opts? {win?:integer}
function M.show(opts)
    opts = opts or {}

    -- Create an immutable scratch buffer that is wiped once hidden
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

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

    -- Launch top, and configure to close the window when the process exits
    vim.fn.termopen({ "top" }, {
        on_exit = function(_, _, _)
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end
    })

    -- Start in terminal mode
    vim.cmd.startinsert()
end

return M
