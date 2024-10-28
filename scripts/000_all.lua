local current_file_path = debug.getinfo(1, "S").source:sub(2)
local parent_dir = vim.fs.dirname(current_file_path)
local filename = vim.fs.basename(current_file_path)

-- Load every script entrypoint except ourself
for name, ty in vim.fs.dir(parent_dir) do
    if ty == "file" and name ~= filename then
        local path = vim.fs.joinpath(parent_dir, name)
        vim.cmd.source(path)
    end
end

-- Assign custom binding to break out of terminal mode (matching my dotfiles)
vim.api.nvim_set_keymap("t", "<C-L><C-L>", "<C-\\><C-n>", { noremap = true })
