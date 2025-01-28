# Configurations for the personal machine setups
{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  sensitive_dir = "${config.home.homeDirectory}/configurations/sensitive";
  project_dir = "${config.home.homeDirectory}/projects/Personal";
  extern_config_dir =
    "${config.home.homeDirectory}/configurations/systems/config/";
in {
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
    ../modules/git.nix
    ../modules/cli-common.nix
    ../modules/languagetool.nix
    ../modules/termgraphics.nix # For handling graphics in terminals
    ../modules/system-manage.nix # System management commands

    # Graphical items
    ../modules/graphical/firefox.nix
    ../modules/graphical/plasma.nix
    ../modules/graphical/terminal.nix
    ../modules/graphical/input.nix
    ../modules/graphical/misc.nix
    ../modules/graphical/steam.nix
    ../modules/graphical/vscode.nix
    ../modules/graphical/cern-work.nix
  ];

  # Miscellaneous one-off packages to install on personal machines
  home.packages = [
    pkgs.apptainer # All non-personal machines should use the system apptainer instance!
  ];

  # Additional session variable to est on local machine
  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "${config.home.homeDirectory}/.mamba";
    KPXC_DATABASE = "${config.home.homeDirectory}/.ssh/credentials.kdbx";
    KRB5CCNAME = "DIR:${config.home.homeDirectory}/.temp.persist";
  };

  # Pulling additional settings from the un-tracked sensitive configurations
  # directory.
  home.file.".ssh/config".source = makeln "${sensitive_dir}/sshconfig";
  home.file.".config/rcb".source = makeln "${sensitive_dir}/config/rcb";
  home.file.".config/nvim-custom/plugins".source = makeln "${project_dir}/nvim-plugins";

  # Additional user-level services that I want to use
  services.syncthing = {
    enable = true;
    extraOptions = [
      "--gui-address=127.0.0.1:8000" # Using port 8000
    ];
  };

  # Alias for system update is different compared with standalone home-manager
  # configurations
  programs.zsh.shellAliases = {
    "system-update" =
      "nh os switch --update --ask $(realpath /etc/nixos/) -- --impure";
    "system-config-update" =
      "nh os switch --ask $(realpath /etc/nixos/) -- --impure";
  };
}

