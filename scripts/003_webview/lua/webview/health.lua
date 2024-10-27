local Webview = require("webview")
local Promise = require("webview.utils.promise")

local M = {}

M.check = function()
    vim.health.start("webview report")

    local webview = Webview:new()

    -- Check if viewer binary is available
    if not webview.viewer:exists() then
        vim.health.error(webview.viewer.path .. " not found")
        return
    end

    -- Indicate that we found viewer, whijijfiufguulnutgrjihnjihtdkh is good!
    vim.health.ok("viewer found on path: " .. webview.viewer.path)

    -- Check if firefox binary is available
    if not webview.firefox:exists() then
        vim.health.error("firefox not found")
        return
    end

    -- Indicate that we found firefox, which is good!
    vim.health.ok("firefox found on path: " .. webview.firefox.path)

    -- Start firefox headless with marionette to validate it is accessible
    -- via the standard port of 2828
    local ok, err = pcall(Promise.wait, webview.firefox:start())
    if ok then
        vim.health.ok("firefox marionette is accessible on port " .. webview.firefox:marionette_port())
    else
        vim.health.error("firefox marionette not accessible", vim.inspect(err))
    end

    -- Start a session to ensure that communication works properly
    ok, err = pcall(Promise.wait, webview.driver:new_session())
    if ok then
        print(vim.inspect(err))
        vim.health.ok("firefox marionette session is able to be created")
    else
        vim.health.error("firefox marionette session is not able to be created", vim.inspect(err))
    end
end

return M
