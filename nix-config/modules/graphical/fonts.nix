{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_config = "${config.home.homeDirectory}/.config/home-manager/config";
  hm_rime = "${hm_config}/../share/fcitx5/rime";
  target_rime = ".local/share/fcitx5/rime";
in {
  home.packages = [
    # Terminal fonts to install
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.zed-mono
    pkgs.fira-code
    pkgs.fira-code-symbols
    # pkgs.nerdfonts.fira-code
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
      monospace = [
        "JetBrainsMono Nerd Font"
        "FiraCode Nerd Font"
        "Noto Sans Mono CJK JP"
      ];
    };
  };

  # Adding additional aliases (Not supported by HM yet...)
  home.file.".config/fontconfig/conf.d/99-alias.conf".source =
    makeln "${hm_config}/fontconfig/conf.d/99-alias.conf";

  # Input method general configurations (keyboard layout and general input
  # method layout)
  home.file.".config/kxkbrc".source = makeln "${hm_config}/kxkbrc";
  home.file.".config/fcitx5/profile".source =
    makeln "${hm_config}/fcitx5/profile";

  # Specific configurations for RIME input method
  home.file."${target_rime}/default.custom.yaml".source =
    makeln "${hm_rime}/default.custom.yaml";
  home.file."${target_rime}/bopomofo_tw.custom.yaml".source =
    makeln "${hm_rime}/bopomofo_tw.custom.yaml";
  home.file."${target_rime}/bopomofo.custom.dict.yaml".source = # Custom phrases are considered sensitive
    makeln
    "${config.home.homeDirectory}/configurations/sensitive/rime/bopomofo.custom.dict.yaml";
}
