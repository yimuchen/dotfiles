{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  plasmadir = "${config.home.homeDirectory}/.config/home-manager/plasma";
in {
  # For workspace setup
  home.file.".local/plasma-org.kde.plasma.desktop-appletsrc".source =
    makeln "${plasmadir}/plasma-org.kde.plasma.desktop-appletsrc";

  # For global behavior
  home.file.".local/kglobalshortcutsrc".source =
    makeln "${plasmadir}/kglobalshortcutsrc";

  # Terminal applications
  home.file.".local/share/konsole/profile.profile".source =
    makeln "${plasmadir}/konsole/profile.profile";
  home.file.".local/share/konsole/Breeze.colorscheme".source =
    makeln "${plasmadir}/konsole/Breeze.colorscheme";
  home.file.".config/yakuakerc".source = makeln "${plasmadir}/yakuakerc";
}
