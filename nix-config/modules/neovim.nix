# Configuration for neovim

# Nix home manager will be used to install packages external to neovim, so any
# binaries cannot be directly installed by the lazy.nvim plugin manager.
# Notice, however, that the nix installation of language server protocols and
# other language-specific tools should be determined by the development
# environment you are working with, and not with this global configuration.
# There are 3 exceptions to this:
#
# - Nix (used to configure global nix settings and package flakes)
# - Markdown (used as my noting format, and not necessarily tied to a package)

{ pkgs, config, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_config = "${config.home.homeDirectory}/.config/home-manager/config";
in {
  programs.neovim = {
    enable = true;

    # Additional package for "global" languages
    #
    # Nix - since all flake needs to be defined before directory can be setup
    # Lua - As any package may require a custom neovim configuration
    # Markdown - Use to generic note taking
    extraPackages = [
      # Common items for neovim
      pkgs.tree-sitter

      # Nix tools
      pkgs.nixfmt-classic
      pkgs.nixd

      # Lua tools
      pkgs.lua-language-server
      pkgs.stylua

      # Markdown tool
      pkgs.ltex-ls
      pkgs.marksman
      pkgs.mdformat
      pkgs.python312Packages.jupytext # For editing notebooks

      # For editing bash scripts
      pkgs.nodePackages.bash-language-server
      pkgs.shfmt

      # Additional tools used by other plugins
      pkgs.ripgrep # For telescope
      pkgs.libgcc # Compiler required for tree-sitter and luarocks
    ];
  };

  # Link to the major configuration path
  home.file.".config/nvim".source = makeln "${hm_config}/nvim";
}
