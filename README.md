# NeovimConf 2024 Talk

An introduction to wrapping your favorite command-line programs as neovim
plugins. Requires neovim 0.10.2, and each individual example may have additional
dependencies.

## Topics

1. High level overview of CLIs 
2. How to run programs and get back data in neovim
3. Building a wrapper around `curl` to display the temperature (using JSON)
4. Embedding `top` in a floating window using `vim.fn.termopen()`
5. Running `firefox` headless, navigating to a website, and displaying the
   website in neovim
6. Creating a tiny UI in a buffer to engage with `sapling`

## Running the presentation

1. Install [presenterm 0.9.0](https://github.com/mfontanini/presenterm).
2. Install [mermaid-ascii 0.6.0](https://github.com/AlexanderGrooff/mermaid-ascii)
   or higher. For MacOS, you may need to remove quarantine, which you can do via
   `xattr -dr com.apple.quarantine mermaid-ascii`.

Once the dependencies are installed, run the presentation:

```sh
./presentation.sh
```

## Examples

1. Read more about [temperature](scripts/001_temperature/README.md) to see how
   single action command line utilities can be wrapped. In this example,
   temperature information for a city is pulled from https://wttr.in using
   `curl`.
2. Read more about [top](scripts/002_top/README.md) to see how interactive
   command line utilities can be wrapped. In this example, `top` is used to
   illustrate embedding an interactive program into neovim via terminal.
3. Read more about [webview](scripts/003_webview/README.md) to see how streaming
   command line utilities can be wrapped. In this example, firefox is remote
   controlled to load websites and display screenshots of them in neovim.
4. Read more about [sapling](scripts/004_sapling/README.md) to see how to build
   a buffer to interact with `sapling`, a source control manager, to switch
   between commits.

Each example can be launched with neovim by leverage `-u` with the path to the
script:

```sh
nvim -u scripts/000_all.lua # Loads all of the examples
nvim -u scripts/001_temperature.lua # Loads the temperature example
nvim -u scripts/002_top.lua # Loads the top example
nvim -u scripts/003_webview.lua # Loads the webview example
nvim -u scripts/004_sapling.lua # Loads the sapling example
```
