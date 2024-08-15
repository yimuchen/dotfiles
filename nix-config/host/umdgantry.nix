# Configurations for LPC related setup
{ config, pkgs, ... }: {
  home.username = "yimuchen";
  home.homeDirectory = "/home/yimuchen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/termgraphics.nix # For handling graphics in terminals
    ../modules/misc.nix
    ../modules/hm-paths.nix
  ];

  # Miscellaneous one-off packages.
  home.packages = [ ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
  };
}
