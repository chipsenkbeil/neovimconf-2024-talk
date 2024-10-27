This plugin represents an example of combining multiple processes
together to convert markdown into a webpage and then view it using
firefox, displaying the output as an image within neovim.

```lua
local webview = require("webview"):new()

-- Start the webview, navigate to a website, take a screenshot, and save it to
-- the specified path
webview:start():wait()
webview:navigate("https://chipsenkbeil.com"):wait()
webview:take_screenshot({ path = "/tmp/chipsenkbeil.com.png" }):wait()
webview:stop()
```
