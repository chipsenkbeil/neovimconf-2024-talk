# Temperature Example

This plugin represents an example of a single command process, `curl`.

Individual requests to websites are made by curl, and in this specific scenario
curl is used to feature the temperature from `https://wttr.in`.

### Run example

Use the following to start a minimal setup with the example code:

```sh
nvim -u scripts/001_temperature.lua
```

From there, you can run the neovim command `:Temperature [city]` to print the
temperature as a message. The city is an optional argument.

### Lua Example

If you want to try out the demo code for yourself via Lua, you can run the
following code after importing the example source:

```lua
local temperature = require("temperature")

-- Retrieves temperature for austin, printing it as a message
temperature.print({ location = "austin" })

-- Retrieves the temperature for austin, returning data
local data = temperature.fetch({ location = "austin" })
print("Austin is", data.current_condition.temp_F)
```
