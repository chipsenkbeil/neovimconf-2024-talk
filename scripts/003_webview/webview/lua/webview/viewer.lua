local Promise = require("webview.utils.promise")

---@class webview.Viewer
local M = {}
M.__index = M

---Creates a new viewer instance.
---@return webview.Viewer
function M:new(opts)
    opts = opts or {}

    local instance = {}
    setmetatable(instance, M)

    return instance
end

---Checks if magick is on path & executable.
---
---This is a dependency of `image.nvim`, which we use to display images.
---@return boolean
function M:has_magick()
    return vim.fn.executable("magick") == 1
end

---Opens a floating buffer to view the image.
---@param opts {path:string}
---@return webview.utils.Promise<{win:integer,buf:integer}>
function M:view(opts)
    return Promise.new(function(resolve, reject)
        local function do_view()
            local api = require("image")
            local term = require("image.utils.term")

            -- Create a scratch buffer that is wiped once hidden
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
            vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", "<CMD>close<CR>", { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(buf, "n", "q", "<CMD>close<CR>", { noremap = true, silent = true })

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

            -- Load the image from disk and display it within our floating window
            local image = api.from_file(opts.path, {
                window = win,
                buffer = buf,
                x = 0,
                y = 0,
                width = width,
            })

            -- TODO: This is a hack to enable scrolling for our demo. Ideally, we would use
            --       the image.rendered_geometry.height (in pixels) converted into a total
            --       number of rows in the terminal to translate into how many lines to fill.
            local lines = {}
            for _ = 1, 1000 do
                table.insert(lines, "")
            end
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

            -- Render the image into the buffer
            image:render()

            -- Change to the window that is floating
            vim.api.nvim_set_current_win(win)

            return { win = win, buf = buf }
        end

        vim.schedule(function()
            local ok, res = pcall(do_view)
            if ok then
                resolve(res)
            else
                reject(res)
            end
        end)
    end)
end

return M
