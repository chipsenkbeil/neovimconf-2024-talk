# Webview Example

This plugin represents an example of a streaming process, `firefox`. Note that
this example requires using the [kitty terminal](https://sw.kovidgoyal.net/kitty/)
to function properly. Other terminals may exhibit unexpected behavior.

When firefox is started, it is provided the `--marionette` flag, which opens a
TCP port on 2828 by default. Communication between neovim and firefox happens
over that port to perform actions including navigating to websites and taking
screenshots of the webpages.

### Configure

Install `magick` Lua bindings required for `image.nvim`:

```sh
luarocks --local --lua-version=5.1 install magick
```

### Run example

Use the following to start a minimal setup with the example code:

```sh
nvim -u scripts/003_webview.lua
```

From there, you can run the singular `Webview` neovim command to start firefox,
connect to the marionette port, navigate to the address, and show the page as a
screenshot from within neovim itself.

```vim
:Webview https://chipsenkbeil.com
```

### Lua Example

If you want to try out the demo code for yourself via Lua, you can run the
following code after importing the example source:

```lua
local webview = require("webview")

-- Start the webview, which will launch firefox headless and connect to
-- the marionette port (default of 2828)
webview:start():wait()

-- Issue a webdriver command to navigate to the specified website
webview:navigate("https://chipsenkbeil.com"):wait()

-- Take a screenshot of the entire page and save it to the specified location
webview:take_screenshot({ path = "/tmp/chipsenkbeil.com.png" }):wait()

-- Display the current screen in a floating window, which involves taking and
-- saving another screenshot to disk and then loading it via image.nvim
webview:display_screen():wait()

-- Disconnect from marionette and terminate the headless firefox instance
webview:stop()
```
