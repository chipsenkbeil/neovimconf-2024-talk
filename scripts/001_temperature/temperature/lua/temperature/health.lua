local M = {}

M.check = function()
    vim.health.start("temperature report")

    -- Check if curl is available
    if vim.fn.executable("curl") == 0 then
        vim.health.error("curl not found on path")
        return
    end

    -- Indicate that we found curl, which is good!
    vim.health.ok("curl found on path")

    -- Pull the version information about curl
    local results = vim.system({ "curl", "--version" }, { text = true }):wait()

    -- If we get a non-zero exit code, something went wrong
    if results.code ~= 0 then
        vim.health.error("failed to retrieve curl's version", results.stderr)
        return
    end

    -- Attempt to parse curl's version string to get the
    -- semantic version string, which comes after the word
    -- curl and before the parentheses. (e.g. "curl 8.6.0 (...)")
    --
    -- NOTE: While `vim.version.parse` should return nil on invalid input,
    --       having something really invalid like "abc" will cause it to
    --       throw an error on neovim 0.10.0! Make sure you're using 0.10.2!
    local v = vim.version.parse(vim.split(results.stdout or "", " ")[2])
    if not v then
        vim.health.error("invalid curl version output", results.stdout)
        return
    end

    -- Require curl 8.x.x
    if v.major ~= 8 then
        vim.health.error("curl must be 8.x.x, but got " .. tostring(v))
        return
    end

    -- Curl is a good version, so lastly we'll test the weather site
    vim.health.ok("curl " .. tostring(v) .. " is an acceptable version")

    -- Poll the weather site using curl
    --
    -- NOTE: We must block to be able to report as scheduling a callback
    --       to invoke ok/error for health results in nothing being printed
    results = vim.system({ "curl", "wttr.in" }, { text = true }):wait()
    if results.code == 0 then
        vim.health.ok("wttr.in is accessible")
    else
        vim.health.error("wttr.in is not accessible")
    end
end

return M
