# Neovim configurations and plugins

The organization of neovim configurations largely follows the example found in the tutorial made by the
[ThePrimeagen][primetut]. One notable exception is the me deciding to not user the [`mason`][mason] package manager for
executable that exist externally of neovim (language servers and file formatter). Instead, users are expected use the
primary package manager to handle these, either the system package manager for commonly used tools or `devshell` session
for items that are unique to a single project. All configurations should be written in `lua` instead of `vimscript`.

- Common settings that typically is contained within the neovim in-built API of the are placed in the
  [`lau/customize`](lau/customize), with the main exception being the `lazy_nvim.lua` file, which lists all plugins to
  be installed.
- Global plugin configurations common to all editing sessions are stored in the `lua/customize/lazy` directory.
- Plugin configurations that are more complicate, or are not yet bundled into their own unique package, or benefits from
  configuring multiple packages at one should be placed in the [`./after/plugin/`](./after/plugin/) directory.
- Language specific configurations should be placed in the `./after/ftplugin/` and `./after/queries/` directories.
- Default configurations for calling external tools (language servers and file formatters) should be placed in the
  [`./project-config/`](./project-config/) directory. A special plugin `./after/plugin/project.lua` is used to control
  how such tool are being loaded based on the working directly and working environment. All tools here should have a
  guard to avoid excessive message when certain tools are not found.

[mason]: https://github.com/williamboman/mason.nvim
[primetut]: https://www.youtube.com/watch?v=w7i4amO_zaE
