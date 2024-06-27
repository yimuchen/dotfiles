# Configurations for the personal machine setups
{ config, pkgs, ... }: {
  home.username = "ensc";
  home.homeDirectory = "/home/ensc";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/shell-helper.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/kitty.nix
    ../modules/git.nix
    ../modules/misc.nix # Common one-off packages

    # Graphical items
    ../modules/graphical/firefox.nix
    ../modules/graphical/plasma.nix
    ../modules/graphical/fonts.nix
    ../modules/graphical/misc.nix
  ];

  # Miscellaneous one-off packages to install on personal machines
  home.packages = [ ];

  # Additional session variable to est on local machine
  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
    KPXC_DATABASE = "${config.home.homeDirectory}/.ssh/credentials.kdbx";
    KRB5CCNAME = "DIR:${config.home.homeDirectory}/.temp.persist";
  };

  # Pulling additional settings from the untracked sensitive configurations
  # directory.
  home.file.".ssh/config".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/configurations/sensitive/sshconfig";
  home.file.".ssh/credentials.kdbx".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/configurations/sensitive/credentials.kdbx";

  # Additional user-level services that I want to use
  services.syncthing = {
    enable = true;
    extraOptions = [
      "--gui-address=127.0.0.1:8000" # Using port 8000
    ];
  };
}

