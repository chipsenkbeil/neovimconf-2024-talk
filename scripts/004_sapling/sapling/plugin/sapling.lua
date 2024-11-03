vim.api.nvim_create_user_command("Sapling", function()
    require("sapling").show()
end, {
    desc = "Show the sapling window",
})
