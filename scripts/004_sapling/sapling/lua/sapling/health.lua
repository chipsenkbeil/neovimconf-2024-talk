local M = {}

M.check = function()
    vim.health.start("sapling report")

    -- Check if sapling is available
    if vim.fn.executable("sl") == 0 then
        vim.health.error("sapling not found on path")
        return
    end

    -- Indicate that we found sapling, which is good!
    vim.health.ok("sapling found on path")

    -- Pull the version information about sapling
    local results = vim.system({ "sl", "--version" }, { text = true }):wait()

    -- If we get a non-zero exit code, something went wrong
    if results.code ~= 0 then
        vim.health.error("failed to retrieve sapling's version", results.stderr)
        return
    end

    -- Attempt to parse sapling's version string, which is not standard semver format,
    -- but still parses okay for our purposes.
    --
    -- (e.g. "sapling 0.2.20240718-145624-f4e9df48")
    local raw_version_str = vim.split(results.stdout or "", " ")[2]
    local v = vim.version.parse(raw_version_str)
    if not v then
        vim.health.error("invalid sapling version output", results.stdout)
        return
    end

    -- Require sapling 0.2.x
    if v.major ~= 0 or v.minor ~= 2 then
        vim.health.error("sapling must be 0.2.x, but got " .. tostring(v))
        return
    end

    vim.health.ok("sapling " .. tostring(v) .. " is an acceptable version")
end

return M
