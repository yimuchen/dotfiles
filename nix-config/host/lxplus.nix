# Configurations for the personal machine setups
{ config, pkgs, lib, ... }: {
  home.username = "yichen";
  home.homeDirectory = "/afs/cern.ch/user/y/yichen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/misc.nix
  ];

  # Miscellaneous one-off packages on LPC machines
  home.packages = [
    pkgs.cacert # Required for newer versions of git
    pkgs.clang-tools # For CMSSW development, currently home DIR is too small
  ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
    # Resetting the cert file - required for the new files of nix
    SSL_CERT_FILE = "${config.home.homeDirectory}/etc/ssl/certs/ca-bundle.crt";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Soft linking in AFS currently does not work... defining as path instead.
  # This means that hot reloading of files doesn't work, unfortunately : (
  home.file.".zsh".source = lib.mkForce ../../zsh;
  home.file.".zshrc".source = lib.mkForce ../../zsh/zshrc.zsh;
  home.file.".p10k.zsh".source = lib.mkForce ../../zsh/p10k.zsh;
  home.file.".config/nvim".source = lib.mkForce ../../nvim;
  home.file.".tmux.conf".source = lib.mkForce ../../tmux.conf;

  # Softlinking doesn't work sell in AFS.... requires custom settings
  #home.file.".mamba".source =
  #  config.lib.file.mkOutOfStoreSymlink "/afs/cern.ch/work/y/yichen/mamba";
  #home.file.".conda".source =
  #  config.lib.file.mkOutOfStoreSymlink "/afs/cern.ch/work/y/yichen/conda";
}

