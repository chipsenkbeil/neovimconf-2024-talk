local M = {}

M.check = function()
    vim.health.start("top report")

    -- Check if top is available
    if vim.fn.executable("top") == 0 then
        vim.health.error("top not found on path")
        return
    end

    -- Indicate that we found top, which is good!
    vim.health.ok("top found on path")
end

return M
