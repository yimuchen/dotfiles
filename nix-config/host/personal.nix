# Configurations for the personal machine setups
{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  sensitive_dir = "${config.home.homeDirectory}/configurations/sensitive";
  project_dir = "${config.home.homeDirectory}/projects/Personal";
in {
  home.username = "ensc";
  home.homeDirectory = "/home/ensc";
  home.stateVersion = "23.11"; # DO NOT EDIT!!
  programs.home-manager.enable = true; # Let home-manager handle itself

  # Importing the other modules
  imports = [
    ../modules/neovim.nix
    ../modules/local-shell.nix
    ../modules/cli-common.nix
    ../modules/services.nix

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

  # Pulling additional settings from the un-tracked sensitive configurations
  # directory.
  home.file.".ssh/config".source = makeln "${sensitive_dir}/sshconfig";
  home.file.".config/rcb".source = makeln "${sensitive_dir}/config/rcb";
  home.file.".config/nvim-custom/plugins".source =
    makeln "${project_dir}/nvim-plugins";
}

