# Configurations for the personal machine setups
{ config, pkgs, lib, ... }: {
  home.username = "yichen";
  home.homeDirectory = "/afs/cern.ch/user/y/yichen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/termgraphics.nix # For handling graphics in terminals
    ../modules/cli-common.nix
    ../modules/git.nix
    ../modules/remote_misc.nix
  ];

  # Miscellaneous one-off packages on lxplus machines
  home.packages = [ ];

  # Soft linking in AFS currently does not work... using mkForce as path
  # instead. This means that hot reloading of files doesn't work, unfortunately
  # : (
  home.file.".config/zsh".source = lib.mkForce ../../zsh;
  home.file.".config/nvim".source = lib.mkForce ../../nvim;
  home.file.".config/tmux/_tmux_custom.sh".source =
    lib.mkForce ../../tmux/_tmux_custom.sh;
  home.file.".config/tmux/config_extra.conf".source =
    lib.mkForce ../../tmux/config_extra.conf;
}

