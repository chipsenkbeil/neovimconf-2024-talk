# Weather Example

This plugin represents an example of a single command process, `curl`.

Individual requests to websites are made by curl, and in this specific scenario
curl is used to feature the weather from `https://wttr.in`.

### Run example

Use the following to start a minimal setup with the example code:

```sh
nvim -u scripts/001_weather.lua
```

From there, you can run one of two neovim commands:

1. `:ShowWeather [city]` to display the weather.
2. `:PrintTemperature [city]` to print the temperature as a message.

For both of these commands, they take an optional city, defaulting to an
attempt to detect the current location.

### Lua Example

If you want to try out the demo code for yourself via Lua, you can run the
following code after importing the example source:

```lua
local weather = require("weather")

-- Retrieves temperature for austin, printing it as a message
weather.check_temperature({ location = "austin" })

-- Displays the weather for austin in a floating terminal
weather.show_weather({ location = "austin" })

-- Retrieves the weather for austin, returning data
local data = weather.retrieve_weather({ location = "austin" })
print("Austin is", data.current_condition.temp_F)
print("Austin feels like" data.current_condition.FeelsLikeF)
```
