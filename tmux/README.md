# tmux configuration

I use [tmux] for typically when I can potentially have long running jobs for a specific project directory, especially
over SSH connections. I don't switch directories, as none of the project that I am working warrants having nested
project structures. I typically don't want to use panes, and prefer to relegate each window to just one task. I also
want to have a consistent window order, where each window number has a dedicated function defined by the project in
questions. Because of this, the switch-window method (prefix+number) is wrapped by the
[`tmux_window_launch.py`](./tmux_window_launch.py) python script, that spawn as new window if it doesn't already exist,
as well as automatically handling the windows renaming. The windows layout is handled globally by the
`~/.config/tmux/windows_layout.json` configuration file or in the `.tmux_windows_layout.json` file of the working
directory of tmux. The local layout will overriding the global layout if there is a duplicate item.

The configuration JSON file takes the format as:

```json
{
  "windows_idx": {
    "title": "name to display in tmux",
    "cmd": "Optional, command to run when spawning the window, spawns the default shell if this is not specified",
    "disable": "true/false flag, Do not create window if it doesn't already exist (default to false)"
  }
}
```

The current global default is:

- Window 0 is the default zsh shell for general purposes.
- Window 1 will spawn a neovim instance for file editing.
- Window 9 is reserved for neovim REPL interactions and is disabled by default
- Window 8 will spawn a btop instance

[tmux]: https://tmux.info/
