# Sapling Example

This plugin represents an example of creating a buffer as a UI for a command
line program, and interacting with the buffer to perform CLI actions.

### Run example

Use the following to start a minimal setup with the example code:

```sh
nvim -u scripts/004_sapling.lua
```

From there, you can run the neovim command `:Sapling` to open a window that
displays the results of running `sapling` in the current working directory.

From there, you can press `<Enter>` on a line containing a commit hash to
navigate to that specific commit, which also refreshes the buffer.

### Lua Example

If you want to try out the demo code for yourself via Lua, you can run the
following code after importing the example source:

```lua
local sapling = require("sapling")

-- Goto a specific commit
sapling.goto_rev("abcd")

-- Read the smartlog and display it in a buffer configured for interactions
sapling.show()
```
