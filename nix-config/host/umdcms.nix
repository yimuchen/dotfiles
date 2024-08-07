# Configurations for LPC related setup
{ config, pkgs, ... }: {
  home.username = "yichen";
  home.homeDirectory = "/home/yichen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/misc.nix
  ];

  # Addition settings for each machine
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";

  # Miscellaneous one-off packages on LPC machines
  home.packages = [
    pkgs.cacert # Required for newer versions of git
    pkgs.clang-tools # For CMSSW development!
  ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
    # Resetting the cert file - required for the new files of nix
    SSL_CERT_FILE =
      "${config.home.homeDirectory}/.nix-profile/etc/ssl/certs/ca-bundle.crt";
  };

  # Additional directory soft links to ensure that large files of custom
  # packages are placed in
  home.file.".mamba".source =
    config.lib.file.mkOutOfStoreSymlink "/data/users/yichen/mamba";
  home.file.".conda".source =
    config.lib.file.mkOutOfStoreSymlink "/data/users/yichen/conda";
}


