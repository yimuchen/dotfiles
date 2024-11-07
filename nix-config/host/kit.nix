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
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/git.nix
    ../modules/remote_misc.nix
    ../modules/termgraphics.nix # For handling graphics in terminals
  ];

  # Miscellaneous one-off packages on LPC machines
  home.packages = [
    pkgs.cacert # Required for newer versions of git
    pkgs.clang-tools # For CMSSW development!
  ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    LARGE_STORAGE_DIR = large_storage_dir;
    # Management of large storage should be handled outside of home-manager, as
    # other tools might be started outside of nix shell sessions.
  };
}

