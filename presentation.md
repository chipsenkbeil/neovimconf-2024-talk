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

What are we talking about?
---

![image:width:50%](assets/images/nvim-external-processes-3x.png)

<!-- end_slide -->

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
4. rg
5. ssh
6. top

<!-- end_slide -->

Piping commands into neovim 
---

### Run program connected to a pipe

Running `:!` will execute the command piped (not in a terminal), and output into
a specialized space within neovim. Supplying curl with `-s` will suppress curl's
output of retrieving the response.

We'll specifically use `?T` to force ANSI character response since we cannot
handle color codes in the output.

```vim
:! curl -s "https://wttr.in/?T"
```

<!-- pause -->

### Run program connected to a pipe and place in buffer

Running `:%!` will behave just like `:!`, but place the output into the current
buffer.

```vim
:%! curl -s "https://wttr.in/?T"
```

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
| `:%! {cmd}`             | Same as `:!`, but inserts output into buffer      | No      |
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

<!-- pause -->

```lua
-- Runs asynchronously:
vim.system({'echo', 'hello'}, { text = true }, function(obj) 
    print(obj.code) 
    print(obj.stdout) 
    print(obj.stderr) 
end)
```

```lua
-- Runs synchronously:
local obj = vim.system({'echo', 'hello'}, { text = true }):wait()
-- { code = 0, signal = 0, stdout = 'hello', stderr = '' }
```

<!-- end_slide -->

Writing a wrapper for temperature
---

![image:width:50%](assets/images/temperature-example-visual-3x.png)

<!-- end_slide -->

Temperature: our first plugin
---

In this example, temperature information for a city is pulled from
`https://wttr.in` using `curl`. The website `wttr.in` supports a variety of
methods to output the temperature, and we'll make use of `?format=j1` to return
JSON.

<!-- jump_to_middle -->

![image:width:50%](assets/images/temperature-example-3x.png)

<!-- end_slide -->
Temperature: checking the tools
---

What do we want it to do?

1. Check that `curl` exists
2. Ensure that `curl` is a version we expect
3. Verify that `https://wttr.in` (used to get temperature) is accessible

<!-- pause -->

Neovim provides a simplistic framework to validate conditions for a
plugin, and we can use this to both ensure that a CLI program is
installed and is the right version.

A standard practice is to include a `health.lua` file at the root of your
plugin that returns a check function, which you can invoke via `:checkhealth
MY_PLUGIN`.

```lua
local M = {}

M.check = function()
    vim.health.start("foo report")
    if check_setup() then
         vim.health.ok("Setup is correct")
    else
         vim.health.error("Setup is incorrect")
    end
end

return M
```

<!-- end_slide -->

Temperature: looking at health.lua
---

### Does curl exist?

```lua
if vim.fn.executable("curl") == 0 then 
    vim.health.error("curl not found")
end
```

<!-- pause -->

### Is curl the right version?

```lua
local results = vim.system({ "curl", "--version" }):wait()
local version = vim.version.parse(results.stdout)
if version.major ~= 8 then 
    vim.health.error("curl must be 8.x.x, but got " .. tostring(version))
end
```

<!-- pause -->

### Is https://wttr.in accessible?

```lua
local results = vim.system({ "curl", "wttr.in" }):wait()
if results.code ~= 0 then 
    vim.health.error("wttr.in is not accessible")
end
```

<!-- end_slide -->

Temperature: implementing 
---

<!-- end_slide -->

Writing a wrapper for top
---

![image:width:50%](assets/images/top-example-visual-3x.png)

<!-- end_slide -->

Writing a wrapper for firefox
---

![image:width:50%](assets/images/webview-example-visual-3x.png)

<!-- end_slide -->

Writing a wrapper for sapling
---

![image:width:50%](assets/images/sapling-example-visual-3x.png)


<!-- end_slide -->

Credits
---

1. *Andrei Neculaesei* for both writing `image.nvim` and directly helping me
   diagnose issues with its use as a means to display browser screenshots
   with scrolling functionality in the `webview` example.

<!-- end_slide -->

References
---

1. [](https://neovim.io/doc/user/lua.html#vim.system() "vim.system()")
1. [](https://neovim.io/doc/user/luvref.html#uv.spawn() "uv.spawn()")

<!-- end_slide -->
