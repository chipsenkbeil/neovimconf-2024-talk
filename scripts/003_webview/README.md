This plugin represents an example of combining multiple processes
together to convert markdown into a webpage and then view it using
firefox, displaying the output as an image within neovim.

### Configure

Install `magick` Lua bindings required for `image.nvim`:

```sh
luarocks --local --lua-version=5.1 install magick
```

### Run example

```sh
nvim -u scripts/003_webview.lua
```

### Example

```lua
local webview = require("webview"):new()

-- Start the webview, navigate to a website, take a screenshot, and save it to
-- the specified path
webview:start():wait()
webview:navigate("https://chipsenkbeil.com"):wait()
webview:take_screenshot({ path = "/tmp/chipsenkbeil.com.png" }):wait()
webview:display_screen():wait()
webview:stop()
```
