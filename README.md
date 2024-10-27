# NeovimConf 2024 Talk

Materials for my neovimconf talk.

An introduction to wrapping your favorite command-line programs as neovim
plugins. 

## Topics

1. High level overview of CLIs 
2. How to write health checks
3. Wrap CLIs as Lua functions
4. Wrap CLIs as vim commands
5. Interface with CLIs that support JSON or other formats
6. Create a tiny UI in a buffer to engage with a CLI program

## Running the presentation

Install [presenterm 0.9.0](https://github.com/mfontanini/presenterm) or higher
and then use it to start the presentation:

```sh
presenterm -x presentation.md
```

## Trying the examples

### Weather

Open the example with neovim:

```sh
nvim -u scripts/001_weather.lua
```

Run the health check:

```vim
:checkhealth weather
```

Invoke methods to print the temperature and show the weather:

```vim
:lua require("weather").check_temperature({ location = "austin" })
```

```vim
:lua require("weather").show_weather({ location = "austin" })
```

### Webview

Open the example with neovim:

```sh
nvim -u scripts/003_webview.lua
```

Run the health check:

```vim
:checkhealth webview
```

Create some markdown file:

```vim
:e /tmp/page.md
```

Invoke method to display a web view for the markdown file:

```vim
:lua require("webview").show()
```
