# Configuration for neovim

# Nix home manager will be used to install packages external to neovim, so any
# binaries cannot be directy installed by the lazy.nvim plugin manager. Notice,
# however, that the nix installation of language server protocols and other
# language-specific tools should be determined by the development environment
# you are working with, and not with this global configuration. There are 3
# exceptions to this:
#
# - Nix (used to configure global nix settings and package flakes)
# - Markdown (used as my noting format, and not nessecarily tied to a package)

{ pkgs, config, ... }: {
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    # Required for REPL notebook like interaction with image preview
    extraLuaPackages = ps: [ ps.magick ];
    extraPython3Packages = ps: [
      ps.pynvim
      ps.jupyter-client
      # cairosvg # for image rendering
      ps.ipython
      # nbformat
      # ... other python packages
    ];

    # Additional package for "global" languages
    #
    # Nix - since all flake needs to be defined before directory can be setup
    # Lua - As any package may require a custom neovim configuration
    # Markdown - Use to generic note taking
    extraPackages = [
      # Common items for neovim
      pkgs.tree-sitter

      # Nix tools
      pkgs.nixfmt
      pkgs.nixd

      # Lua tools
      pkgs.lua-language-server
      pkgs.stylua

      # Markdown tool
      pkgs.ltex-ls # Currently not working with hybrid setup??
      pkgs.marksman
      pkgs.mdformat

      # Additional tools used by other plugins
      pkgs.ripgrep # For telescope
      pkgs.ueberzugpp # For image display
      pkgs.imagemagick
      pkgs.luarocks # Required for new items
      pkgs.libgcc # Compiler required for tree-sitter and luarocks
    ];
  };

  # Link to the major configuration path
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/nvim";

  home.sessionVariables."EDITOR" = "nvim";

  # Additional packages that are related to neovim usage
  home.packages = [ pkgs.git ];
}
