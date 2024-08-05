{ config, pkgs, ... }:
let
  dotfile_dir = "${config.home.homeDirectory}/.config/home-manager";
  rime_dir = "~/.local/share/fcitx5/rime";
in {
  home.packages = [
    # Terminal fonts to install
    pkgs.fira-code-nerdfont
    # Fonts to be used by system display
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    # Fonts commonly used for typesettings
    pkgs.libertine
    pkgs.libertinus
    pkgs.xits-math
    # Fonts from MS
    pkgs.corefonts
    # Fonts from TW-MoE definitions
    # pkgs.edusong
    # pkgs.eduli
    # pkgs.edukai
    pkgs.ttf-tw-moe
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Noto Sans" "Noto Sans CJK JP" ];
      serif = [ "Linux Libertine Display" "Noto Serif CJK JP" ];
      monospace = [ "FiraCode Nerd Font" "Noto Sans Mono CJK JP" ];
    };
  };

  # Adding additional aliases (Not supported by HM yet...)
  home.file.".config/fontconfig/conf.d/99-alias.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfile_dir}/fontconfig/alias.conf";

  # Input method configurationsi (fcitx with rime) will be consider a part of
  # "font" configurations.
  home.file."${rime_dir}/default.custom.yaml".source =
    config.lib.file.mkOutOfStoreSymlink
    "${dotfile_dir}/fontconfig/default.custom.yaml";
  home.file."${rime_dir}/bopomofo_tw.custom.yaml".source =
    config.lib.file.mkOutOfStoreSymlink
    "${dotfile_dir}/fontconfig/bopomofo_tw.custom.yaml";

}
