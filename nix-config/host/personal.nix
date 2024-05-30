# Configurations for the personal machine setups
{ config, pkgs, ... }: {
  home.username = "ensc";
  home.homeDirectory = "/home/ensc";
  home.stateVersion = "23.11"; # DO NOT EDIT!!

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/shell-helper.nix
    ../modules/zsh.nix
    ../modules/kitty.nix
    ../modules/misc.nix # Common on-off packages
    # ../modules/graphical/misc.nix
    # ../modules/graphical/firefox.nix
  ];

  # Miscellaneous one-off packages to install on personal machines
  home.packages = [ ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

