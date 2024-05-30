# Configurations for the personal machine setups
{ config, pkgs, ... }: {
  home.username = "yimuchen";
  home.homeDirectory = "/uscms/homes/y/yimuchen";
  home.stateVersion = "23.11"; # DO NOT EDIT!!

  # Importing the other modules
  imports = [ ../modules/neovim.nix ../modules/zsh.nix ../modules/misc.nix ];

  # Miscellaneous one-off packages on LPC machines
  home.packages = [ ];

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
    # Resetting the cert file - required for the new files of nix
    SSL_CERT_FILE =
      "${config.home.homeDirectory}/.nix-profile/etc/ssl/certs/ca-bundle.crt";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Additional directory soft links to ensure that large files of custom
  # packages are placed in
  home.file.".mamba".source =
    config.lib.file.mkOutOfStoreSymlink "/uscms_data/d3/yimuchen/mamba";
  home.file.".conda".source =
    config.lib.file.mkOutOfStoreSymlink "/uscms_data/d3/yimuchen/conda";
  # Exposing the system settings as part of the installation
  #home.file.".nix-profile/etc/passwd".source =
  #  config.lib.file.mkOutOfStoreSymlink "/etc/passwd";
}

