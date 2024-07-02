{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  plasmadir = "${config.home.homeDirectory}/.config/home-manager/plasma";
in {
  # Additional packages to install for themeing configurations
  home.packages = [
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.qt6gtk2
    pkgs.arc-theme
    pkgs.arc-kde-theme
    pkgs.papirus-icon-theme
  ];

  # For global behavior
  home.file.".config/kglobalshortcutsrc".source =
    makeln "${plasmadir}/kglobalshortcutsrc";

  # Terminal applications
  home.file.".local/share/konsole/profile.profile".source =
    makeln "${plasmadir}/konsole/profile.profile";
  home.file.".local/share/konsole/Breeze.colorscheme".source =
    makeln "${plasmadir}/konsole/Breeze.colorscheme";
  home.file.".config/yakuakerc".source = makeln "${plasmadir}/yakuakerc";
}
