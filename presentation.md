---
title: Wrapping your favorite CLI in neovim
sub_title: By building plugins in neovim 0.10.2
author: Chip Senkbeil
theme:
  name: catppuccin-macchiato
  override:
    footer:
      style: empty
---

What is a command-line interface?
---

> A means to interact with a computer program by inputting lines of text called _command-lines_.
>
> Source: [](https://en.wikipedia.org/wiki/Command-line_interface)

<!-- pause -->

If you use neovim, you're no doubt familiar with these and use them all the
time. Here are some examples:

1. curl
2. docker
3. git
4. ssh
5. top

<!-- end_slide -->

Kinds of CLIs you might interact with
---

<!-- pause -->
1. Command-oriented: do one thing with each execution.
    1. `curl` transfers data using network protocols like HTTP
    2. `git` can retrieve & manipulate git repositories
    3. `docker` exposes commands to run and manage containers
<!-- new_line -->
<!-- pause -->
2. Stream-oriented: do many things over standard or network I/O.
    1. `rust-analyzer` accepts requests and responds via JSON over stdin/stdout
    2. `firefox` can be remote controlled via marionette over TCP
    3. `rg` supports outputting results to stdout as a stream of lines of JSON
<!-- new_line -->
<!-- pause -->
3. Interactive: do many things with a user interface & keyboard input.
    1. `top` displays an ever-changing list of processes
    2. `bash` continuously accepts commands and execute them
    3. `lazygit` provides a terminal user interface (TUI) to do git operations

<!-- end_slide -->

How to invoke CLIs from neovim (old way)
---

Up to neovim 0.9, we needed a variety of different APIs to invoke external
processes in neovim:

| Method                  | Description                                       | Async?  |
| ----------------------- | ------------------------------------------------- | ------- |
| `:! {cmd}`              | Run {cmd} in shell connected to a pipe            | No      |
| `:terminal {cmd}`       | Run {cmd} in non-interactive shell connected pty  | **Yes** |
| `:call system({cmd})`   | Run {cmd} and get output as a string              | No      |
| `:call termopen({cmd})` | Run {cmd} in pseudo-terminal in current buffer    | **Yes** |
| `io.popen()`            | Executes shell command (part of Lua stdlib)       | **Yes** |
| `uv.spawn()`            | Asynchronously process spawn (part of luv)        | **Yes** |
| `fn.system({cmd})`      | Same as vim command `system({cmd})`               | No      |
| `fn.termopen({cmd})`    | Spawns {cmd} in a new pseudo-terminal session     | **Yes** |
| `api.nvim_open_term()`  | Creates a new terminal without a process          | **Yes** |

<!-- end_slide -->

How to invoke CLIs from neovim (new way)
---

With the introduction of `vim.system()` in neovim 0.10, the act of executing
processes synchronously or asynchronously is streamlined! So now we care about:

| Method                  | Description                                     | Async?    |
| ----------------------- | ----------------------------------------------- | --------- |
| `vim.system()`          | Run {cmd} synchronously or asynchronously       | **Both**  |
| `fn.termopen({cmd})`    | Spawns {cmd} in a new pseudo-terminal session   | **Yes**   |
| `api.nvim_open_term()`  | Creates a new terminal without a process        | **Yes**   |

<!-- pause -->

We're just going to focus on the first two. Rarely do you want to use
`nvim_open_term()` unless you are proxying a process. A particular use case is
`distant.nvim` proxying your remote shell as if it was open in neovim.

<!-- end_slide -->

<!-- jump_to_middle -->

Writing a plugin
===

<!-- end_slide -->

Health checks
---

Neovim provides a simplistic framework to validate conditions for a
plugin, and we can use this to both ensure that a CLI program is
installed and is the right version.

```vim
:checkhealth weather
```

```lua
vim.notify("Hello world!")
```

<!-- end_slide -->

Wrapping as a Lua function
---

TODO

<!-- end_slide -->

Wrapping as a vim command
---

TODO

<!-- end_slide -->

CLIs with structured formats
---

TODO

<!-- end_slide -->

Building a UI for your plugin
---

TODO

<!-- end_slide -->

References
---

1. [](https://neovim.io/doc/user/lua.html#vim.system() "vim.system()")
1. [](https://neovim.io/doc/user/luvref.html#uv.spawn() "uv.spawn()")

<!-- end_slide -->
