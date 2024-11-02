local current_file_path = debug.getinfo(1, "S").source:sub(2)
local parent_dir = vim.fs.dirname(current_file_path)
local filename_with_ext = vim.fs.basename(current_file_path)
local _, _, filename = filename_with_ext:find("^(.*)%.lua$")
local plugin_dir = vim.fs.joinpath(parent_dir, filename)
for name, ty in vim.fs.dir(plugin_dir) do
    if ty == "directory" then
        vim.opt.rtp:append(vim.fs.joinpath(plugin_dir, name))
    end
end

-- Configure Neovim to load user-installed Lua rocks libraries:
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

-- Setup image.nvim for our viewer
require("image").setup({
    max_width = nil,
    max_height = nil,
    max_width_window_percentage = false,
    max_height_window_percentage = false,
    window_overlap_clear_enabled = false,
})
