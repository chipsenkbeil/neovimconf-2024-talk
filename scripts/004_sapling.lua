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
