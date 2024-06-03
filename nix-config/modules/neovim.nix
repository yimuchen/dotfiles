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

    # Additional package for global languages
    extraPackages = [
      # Common items for neovim
      pkgs.tree-sitter

      # Nix tools for global nix configurations
      pkgs.nixfmt
      pkgs.nixd

      # Markdown tool
      # pkgs.ltex-ls # Currently not working with hybrid setup?? Fix in the future
      pkgs.marksman
      pkgs.mdformat

      # Additional tools used by other plugins
      pkgs.ripgrep # For telescope
      pkgs.ueberzugpp # For image display
      pkgs.imagemagick

    ];
  };

  # Link to the major configuration path
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/nvim";

  # Additional packages that are related to neovim usage
  home.packages = [ pkgs.git ];
}