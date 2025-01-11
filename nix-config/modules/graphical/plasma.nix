{ config, pkgs, ... }:
# General configuration for plasma workspace look-and-feel. Components that
# require longer files to define should be placed in the "plasma-workspace"
# folder, and the file there should not contain any logic
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_config = "${config.home.homeDirectory}/.config/home-manager/config";

  # Fixing certain non-KDE items crashing on file selection.
  # https://github.com/NixOS/nixpkgs/issues/149812#issuecomment-1144285380
  missing-gsettings-schemas-fix = builtins.readFile
    "${pkgs.stdenv.mkDerivation {
      name = "missing-gsettings-schemas-fix";
      dontUnpack = true; # Make it buildable without “src” attribute
      buildInputs = [ pkgs.gtk3 ];
      installPhase = ''printf %s "$GSETTINGS_SCHEMAS_PATH" >"$out"'';
    }}";
in {
  home.packages = [
    # Additional packages to install for themeing configurations
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.qt6gtk2
    pkgs.arc-theme
    pkgs.arc-kde-theme
    pkgs.papirus-icon-theme
  ];

  # For global behavior
  home.file.".config/kglobalshortcutsrc".source =
    makeln "${hm_config}/kglobalshortcutsrc";

  # Fixing some QT-GTK interaction oddities
  home.sessionVariables.XDG_DATA_DIRS =
    "$XDG_DATA_DIRS:${missing-gsettings-schemas-fix}";

  programs.plasma = {
    enable = true;
    workspace = {
      theme = "Arc-Dark";
      cursor = {
        theme = "Adwaita";
        size = 24;
      };
      iconTheme = "Papirus-Dark";
    };
    panels = [ ./plasma-workspace/task-panel-primary.nix ];
  };

}
