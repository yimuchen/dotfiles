{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_config = "${config.home.homeDirectory}/.config/home-manager/config";
  hm_share = "${config.home.homeDirectory}/.config/home-manager/share";
in {
  home.packages = [
    # Additional packages to install for themeing configurations
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.qt6gtk2
    pkgs.arc-theme
    pkgs.arc-kde-theme
    pkgs.papirus-icon-theme

    # Core GUI programs that we want to keep centrally managed
    pkgs.kdePackages.yakuake
    # pkgs.kdePackages.konsole # We would probably keep this around as a backup
    pkgs.ghostty
  ];

  # For global behavior
  home.file.".config/kglobalshortcutsrc".source =
    makeln "${hm_config}/kglobalshortcutsrc";

  # Terminal applications
  home.file.".local/share/konsole/profile.profile".source =
    makeln "${hm_share}/konsole/profile.profile";
  home.file.".local/share/konsole/Breeze.colorscheme".source =
    makeln "${hm_share}/konsole/Breeze.colorscheme";
  home.file.".config/yakuakerc".source = makeln "${hm_config}/yakuakerc";
  home.file.".config/ghostty/config".source =
    makeln "${hm_config}/ghostty/config";
}
