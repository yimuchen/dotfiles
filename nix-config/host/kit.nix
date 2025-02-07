# Configurations for KIT cluster setup
{ config, pkgs, ... }: {
  home.username = "ychen";
  home.homeDirectory = "/home/ychen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/remote-shell.nix
    ../modules/cli-common.nix
  ];

  # Miscellaneous one-off packages on KIT machines
  home.packages = [ ];
}

