# Configurations for LPC related setup
{ config, pkgs, ... }: {
  home.username = "yichen";
  home.homeDirectory = "/home/yichen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/cli-common.nix
    ../modules/remote_misc.nix
  ];

  # Miscellaneous one-off packages on LPC machines
  home.packages = [];
}

