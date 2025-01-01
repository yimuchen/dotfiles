{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  plasmadir = "${config.home.homeDirectory}/.config/home-manager/plasma";
  dotfile_dir = "${config.home.homeDirectory}/.config/home-manager";
  target_rime_dir = ".local/share/fcitx5/rime";
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
      monospace = [ "FiraCode Nerd Font" "Noto Sans Mono CJK JP" ];
    };
  };

  # Adding additional aliases (Not supported by HM yet...)
  home.file.".config/fontconfig/conf.d/99-alias.conf".source =
    makeln "${dotfile_dir}/fontconfig/alias.conf";

  # Input method general configurations (keyboard layout and general input
  # method layout)
  home.file.".config/kxkbrc".source = makeln "${plasmadir}/kxkbrc";
  home.file.".config/fcitx5/profile".source =
    makeln "${plasmadir}/fcitx5-profile";

  # Individual input method configurations
  home.file."${target_rime_dir}/default.custom.yaml".source =
    makeln "${dotfile_dir}/fontconfig/default.custom.yaml";
  home.file."${target_rime_dir}/bopomofo_tw.custom.yaml".source =
    makeln "${dotfile_dir}/fontconfig/bopomofo_tw.custom.yaml";
  home.file."${target_rime_dir}/bopomofo.custom.dict.yaml".source = # Custom phrases are considered sensitive
    makeln
    "${config.home.homeDirectory}/configurations/sensitive/rime/bopomofo.custom.dict.yaml";
}
