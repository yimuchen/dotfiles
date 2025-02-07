# Configurations for LPC related setup
{ config, pkgs, ... }: {
  home.username = "yimuchen";
  home.homeDirectory = "/uscms/homes/y/yimuchen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/remote-shell.nix
    ../modules/cli-common.nix
  ];

  # Miscellaneous one-off packages on LPC machines
  home.packages = [ ];

}

