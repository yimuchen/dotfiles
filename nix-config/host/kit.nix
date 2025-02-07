# Configurations for LPC related setup
{ config, pkgs, ... }:
let large_storage_dir = "/work/ychen";
in {
  home.username = "ychen";
  home.homeDirectory = "/home/ychen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/tmux.nix
    ../modules/remote_misc.nix
    ../modules/cli-common.nix
    ../modules/termgraphics.nix # For handling graphics in terminals
  ];

  # Miscellaneous one-off packages on KIT machines
  home.packages = [ ];
}

