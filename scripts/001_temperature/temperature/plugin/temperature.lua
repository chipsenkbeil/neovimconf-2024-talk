vim.api.nvim_create_user_command("Temperature", function(opts)
    local location
    if string.len(opts.args) > 0 then
        location = opts.args
    end

    require("temperature").print({ location = location })
end, {
    nargs = "*",
    desc = "Check the temperature",
})
