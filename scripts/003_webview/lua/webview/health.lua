local M = {}

-- Used as a headless browser to preview webpages
local FIREFOX_MAC_PATH = "/Applications/Firefox.app/Contents/MacOS/firefox"
local FIREFOX_BIN_PATH = "firefox"

-- Used to display images/videos in the terminal
local TIMG_BIN_PATH = "timg"

local MARIONETTE_HOST = "127.0.0.1"
local MARIONETTE_PORT = 2828

M.check = function()
    vim.health.start("webview report")

    -- Check if timg is available
    if vim.fn.executable(TIMG_BIN_PATH) == 0 then
        vim.health.error("timg not found on path")
        return
    end

    -- Indicate that we found timg, which is good!
    vim.health.ok("timg found on path: " .. TIMG_BIN_PATH)

    -- Check if firefox is available
    --
    -- On MacOS, this would be within the application
    local bin = FIREFOX_BIN_PATH
    if vim.fn.executable(bin) == 0 then
        bin = FIREFOX_MAC_PATH
    end
    if vim.fn.executable(bin) == 0 then
        vim.health.error("firefox not found on path")
        return
    end

    -- Indicate that we found firefox, which is good!
    vim.health.ok("firefox found on path: " .. bin)

    -- Start firefox headless with marionette to validate it is accessible
    -- via the standard port of 2828
    --
    -- Run it asynchronously to ensure that we don't block our script
    local proc = vim.system({ bin, "--marionette", "--headless" }, { text = true })

    -- Wait for half a second so we don't accidentally access too early
    --
    -- NOTE: I haven't actually had this issue, but doing it anyway!
    vim.wait(500)

    ---@type {err?:string, data?:string}
    local response = {}

    -- Connect to the port via TCP and receive a JSON message
    local client = vim.uv.new_tcp()
    client:connect(MARIONETTE_HOST, MARIONETTE_PORT, function(err)
        if err then
            response.err = err
            return
        end

        -- Process data from the marionette port
        client:read_start(function(err, chunk)
            if err then
                response.err = err
            elseif chunk then
                response.data = chunk
            else
                response.err = "disconnected"
            end

            -- Force stream to stop after we got anything
            client:read_stop()
            client:close()
        end)
    end)

    local function has_response()
        return response.err ~= nil or response.data ~= nil
    end

    -- Wait for something to happen, up to a few seconds
    if not vim.wait(3000, has_response, 500) then
        vim.health.error("firefox marionette did not respond")
    elseif response.data then
        vim.health.ok("firefox marionette is accessible on port " .. MARIONETTE_PORT)
    elseif response.err then
        vim.health.error("firefox marionette is not accessible", response.err)
    end

    proc:kill("sigkill")
end

return M
