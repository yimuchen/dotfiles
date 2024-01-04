# Neovim configurations and plugins

For this configuration, all configurations should be written in lua (rather
than vimscript) for a more consistent reading experience.

Additional handling of plugins and LSPs will be defined in their respective
`after/<plugin>.lua` configuration files.

## External dependencies

Certain external dependencies needs to be installed to get the most out of the
editor experience. The neovim plugin [`mason`][mason] is commonly used for
external package management. To ensure the same formatters are used by the
external command line interface (as you might want to perform linting and
formatting outside at neovim session), the mason path should be exposed as part
of the `$PATH` environment variables, which is handled in the
`zsh/personal_tools.sh` shell script configuration. An exception to this rule
would be the formatter and linting tools for python, which should be coupled
with the python virtual environment used for the session. (By default we will
assume that the user will set up python virtual environments using
[`conda`][conda], where we set always attempt to provide [`black`][black] and
[`isort`][isort] as the default formatter).

As file formatting will likely be project specific, the formatter would detect
the current working directory and find if a corresponding configuration files
exists, and use the corresponding formatter (TODO). This repository also stores
the default formatting configuration files in the [`format_cfg`](format_cfg)
directory to fall back to if not formatter configuration was found.


[mason]: https://github.com/williamboman/mason.nvim
[conda]: https://docs.conda.io/en/latest/
[black]: https://github.com/psf/black
[isort]: https://pycqa.github.io/isort/
