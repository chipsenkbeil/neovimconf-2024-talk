# Top Example

This plugin represents an example of an interactive process, `top`.

### Run example

Use the following to start a minimal setup with the example code:

```sh
nvim -u scripts/002_top.lua
```

From there, you can run the neovim command `:Top` to bring up a floating window
running the top process.

### Lua Example

If you want to try out the demo code for yourself via Lua, you can run the
following code after importing the example source:

```lua
local top = require("top")

-- Open a window running top
top.show()
```
