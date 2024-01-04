# Neovim configurations and plugins

All configurations are written in `lua`.

- Common settings that typically is contained within the neovim in-built API of
  the are placed in the [`lau/customize`](lau/customize), with the main
  exception being the `lazy_nvim.lua` file, which lists all plugins to be
  installed.
- Plugin and LSP specific configurations are stored in the corresponding
  `after/<plugin>.lua` files.
- External configuration for text editing tools not strictly used just for
  neovim (mainly for text formatting tools) will be stored in `external`
  directory.

## Decision on external dependencies

To allow for this neovim configuration to be portable, we will attempt to have
that [`mason`][mason] manage external tools used for text editing. If you want
to use the same formatters in the usual command-line interface (as you might
want to perform linting and formatting outside at neovim session), the mason
path should be exposed as part of the `$PATH` environment variables (by default
this should be `$HOME/.local/share/nvim/mason/bin`). One exception to this rule
would be the formatter and linting tools for python, which should be coupled
with the python virtual environment used for the session. (By default we will
assume that the user will set up python virtual environments using
[`conda`][conda], where we set always attempt to provide [`black`][black] and
[`isort`][isort] as the default formatter).

[mason]: https://github.com/williamboman/mason.nvim
[conda]: https://docs.conda.io/en/latest/
[black]: https://github.com/psf/black
[isort]: https://pycqa.github.io/isort/
