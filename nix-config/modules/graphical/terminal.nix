{ config, pkgs, ... }:
# Definition of terminal emulator programs. Because I'm very picky with that
# terminal experiences should be uniform, I am splitting this out as a
# separate configuration file
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_config = "${config.home.homeDirectory}/.config/home-manager/config";
  hm_share = "${config.home.homeDirectory}/.config/home-manager/share";

in {
  # List of terminal programs that we will be using
  home.packages = [
    pkgs.kdePackages.yakuake
    # pkgs.kdePackages.konsole # We would probably keep this around as a backup
    pkgs.ghostty
  ];
  programs.konsole.enable = false; # Now disabling Konsole by default

  # Configuration that is set by nix-configurations (Hot key configurations)
  programs.plasma.shortcuts = {
    "yakuake"."toggle-window-state" = "Meta+X";
    "services/org.kde.ghostty.desktop"."_launch" = "Meta+Alt+T";
  };

  # Terminal applications
  home.file.".local/share/konsole/profile.profile".source =
    makeln "${hm_share}/konsole/profile.profile";
  home.file.".local/share/konsole/Breeze.colorscheme".source =
    makeln "${hm_share}/konsole/Breeze.colorscheme";
  home.file.".config/yakuakerc".source = makeln "${hm_config}/yakuakerc";
  home.file.".config/ghostty/config".source =
    makeln "${hm_config}/ghostty/config";

}

