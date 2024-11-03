vim.api.nvim_create_user_command("Top", function()
    require("top").show()
end, {
    desc = "Show the top window",
})
