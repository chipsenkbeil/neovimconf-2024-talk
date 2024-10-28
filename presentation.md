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

<!-- end_slide -->

<!-- jump_to_middle -->

Writing a weather plugin
===

<!-- end_slide -->

Weather: our first plugin
---

In this example, weather information for a city is pulled from `https://wttr.in`
using `curl`. The website `wttr.in` supports a variety of methods to output
the weather, and we'll make use of `?format=j1` to return JSON.

```bash +exec_replace +no_background
mermaid-ascii -p 0 << EOF
graph TD
curl -->|GET https://wttr.in?format=j1| wttr.in
wttr.in -->|HTTP 200| JSON response
EOF
```

<!-- end_slide -->

Weather: testing the command
---

Before building a function around `curl`, we should test it first. An easy way
to do this without leaving neovim is to use `:!`.

<!-- pause -->

### Run program connected to a pipe

Running `:!` will execute the command piped (not in a terminal), and output into
the TODO. Supplying curl with `-s` will suppress curl's output of retrieving the
response.

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

Weather: checking the tools (1/3)
---

What do we want it to do?

1. Check that `curl` exists
2. Ensure that `curl` is a version we expect
3. Verify that `https://wttr.in` (used to get weather) is accessible

<!-- pause -->

Neovim provides a simplistic framework to validate conditions for a
plugin, and we can use this to both ensure that a CLI program is
installed and is the right version.

<!-- pause -->

### Check that curl exists

Write a file in your plugin. For this example, `lua/weather/health.lua`:

```lua
vim.health.start("weather health check")

-- Check if curl is available, returns 1 if executable, 0 if not
if vim.fn.executable("curl") == 0 then
    vim.health.error("curl not found on path")
    return
end

-- Indicate that we found curl, which is good!
vim.health.ok("curl found on path")
```

<!-- end_slide -->

Weather: checking the tools (2/3)
---

### Validate curl's version

```lua
-- Pull the version information about curl
local results = vim.system({ "curl", "--version" }, { text = true }):wait()

-- If we get a non-zero exit code, something went wrong
if results.code ~= 0 then
    vim.health.error("failed to retrieve curl's version", results.stderr)
    return
end

-- Attempt to parse curl's version string, which looks like "curl 8.6.0 (...)"
local v = vim.version.parse(vim.split(results.stdout or "", " ")[2])
if not v then
    vim.health.error("invalid curl version output", results.stdout)
    return
end

-- Require curl 8.x.x
if v.major ~= 8 then
    vim.health.error("curl must be 8.x.x, but got " .. tostring(v))
    return
end

-- Curl is a good version, so lastly we'll test the weather site
vim.health.ok("curl " .. tostring(v) .. " is an acceptable version")
```

<!-- end_slide -->

Weather: checking the tools (3/3)
---

### Ensure wttr.in is accessible

```lua
-- Poll the weather site using curl
--
-- NOTE: We must block to be able to report as scheduling a callback
--       to invoke ok/error for health results in nothing being printed
results = vim.system({ "curl", "wttr.in" }, { text = true }):wait()
if results.code == 0 then
    vim.health.ok("wttr.in is accessible")
else
    vim.health.error("wttr.in is not accessible")
end
```

<!-- pause -->

### Perform the health check

Running `:checkhealth` with the name of the plugin will invoke our `check()`
function containing the earlier logic.

```vim
:checkhealth weather
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
