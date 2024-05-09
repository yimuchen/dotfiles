# Neovim configurations and plugins

All configurations are written in `lua`.

- Common settings that typically is contained within the neovim in-built API of
  the are placed in the [`lau/customize`](lau/customize), with the main
  exception being the `lazy_nvim.lua` file, which lists all plugins to be
  installed.
- Global plugin configurations common to all editing sessions are stored in the
  `lua/customize/lazy` directory.
- Language specific configuration should be defined in each of their
  `after/plugin/lspconfig-<language>.lua` file. Additional plugin
  configurations should also be placed here.

## Decision on external dependencies

Nix should be used to handled external dependencies. See the corresponding
[`neovim.nix`](../nix-config/modules/neovim.nix) file to ensure that the
required package are installed (Or install these globally using your own
package manager if you are not using nix). Notice that language specific
packages (language servers and formatters) should be installed in your
development shell rather than globally, as this ensures that the tools used
for editing matches the tools used for building and running the code.
