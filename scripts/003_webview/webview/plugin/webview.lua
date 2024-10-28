vim.api.nvim_create_user_command("Webview", function(opts)
    local url = opts.args
    if string.len(url) == 0 then
        error("missing url")
    end

    vim.schedule(function()
        local webview = require("webview"):new()
        webview:start():next(function()
            print("Navigating to", url)
            return webview:navigate(url)
        end):next(function()
            print("Displaying", url)
            return webview:display_screen()
        end):next(function()
            return webview:stop()
        end):catch(function(err)
            vim.api.nvim_err_writeln(err)
        end)
    end)
end, {
    nargs = "*",
    desc = "Load a website and display it",
})
