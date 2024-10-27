vim.api.nvim_create_user_command("PrintTemperature", function(opts)
    local location
    if string.len(opts.args) > 0 then
        location = opts.args
    end

    require("weather").check_temperature({ location = location })
end, {
    nargs = "*",
    desc = "Print the temperature",
})

vim.api.nvim_create_user_command("ShowWeather", function(opts)
    local location
    if string.len(opts.args) > 0 then
        location = opts.args
    end

    require("weather").show_weather({ location = location })
end, {
    nargs = "*",
    desc = "Show the weather",
})
