{ config, pkgs, ... }:
# General configuration for plasma workspace look-and-feel. Components that
# require longer files to define should be placed in the "plasma-workspace"
# folder, and the file there should not contain any logic
let
  # Fixing certain non-KDE items crashing on file selection.
  # https://github.com/NixOS/nixpkgs/issues/149812#issuecomment-1144285380
  missing-gsettings-schemas-fix = builtins.readFile
    "${pkgs.stdenv.mkDerivation {
      name = "missing-gsettings-schemas-fix";
      dontUnpack = true; # Make it buildable without “src” attribute
      buildInputs = [ pkgs.gtk3 ];
      installPhase = ''printf %s "$GSETTINGS_SCHEMAS_PATH" >"$out"'';
    }}";
  panel_base = (import ./plasma-workspace/task-panel-primary.nix) { };
  panel_0 = pkgs.lib.recursiveUpdate panel_base { screen = 0; };
  panel_1 = pkgs.lib.recursiveUpdate panel_base { screen = 1; };
in {
  home.packages = [
    # Additional packages to install for themeing configurations
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.qt6gtk2
    pkgs.arc-theme
    pkgs.arc-kde-theme
    pkgs.papirus-icon-theme
  ];

  # We are still managing shortcuts by symlinking for the time being

  # Fixing some QT-GTK interaction oddities
  home.sessionVariables.XDG_DATA_DIRS =
    "$XDG_DATA_DIRS:${missing-gsettings-schemas-fix}";

  programs.plasma = {
    enable = true;
    workspace = (import ./plasma-workspace/workspace-theme.nix) { };
    panels = [ panel_0 panel_1 ];
    krunner = { # krunner has it's own configuration
      activateWhenTypingOnDesktop = false;
      position = "center";
      shortcuts = { launch = "Meta"; };
    };
  };

}
