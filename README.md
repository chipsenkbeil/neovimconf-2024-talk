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

Install [presenterm](https://github.com/mfontanini/presenterm) and then use it
to start the presentation:

```sh
presenterm -x presentation.md
```

## Trying the examples

### Health check

Open the example with neovim:

```sh
nvim -u examples/health
```
