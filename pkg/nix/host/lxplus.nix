# Configurations for the personal machine setups
{ config, pkgs, lib, ... }: {
  home.username = "yichen";
  home.homeDirectory = "/afs/cern.ch/user/y/yichen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/remote_misc.nix
    ../modules/cli-common.nix
  ];

  # Miscellaneous one-off packages on lxplus machines
  home.packages = [ ];
}

