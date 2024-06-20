# Configurations for the personal machine setups
{ config, pkgs, ... }: {
  home.username = "ensc";
  home.homeDirectory = "/home/ensc";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/shell-helper.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/kitty.nix
    ../modules/misc.nix # Common one-off packages

    # Graphical items
    ../modules/graphical/fonts.nix
    # ../modules/graphical/misc.nix
    # ../modules/graphical/firefox.nix
  ];

  # Miscellaneous one-off packages to install on personal machines
  home.packages = [ ];

  # Additional session variable to est on local machine
  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
  };
}

