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

  # Configuration for global font settings fall backs
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

  # Plasma font configurations
  programs.plasma.fonts = {
    fixedWidth.family = "JetBrainsMono Nerd Font";
    fixedWidth.pointSize = 12;
    general.family = "Noto Sans CJK JP";
    general.pointSize = 12;
    menu.family = "Noto Sans CJK JP";
    menu.pointSize = 12;
    small.family = "Noto Sans CJK JP";
    small.pointSize = 11;
    toolbar.family = "Noto Sans CJK JP";
    toolbar.pointSize = 10;
    windowTitle.family = "Noto Sans CJK JP";
    windowTitle.pointSize = 12;
  };

  # Configurations for the input methods
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chewing
      fcitx5-anthy
      fcitx5-chinese-addons
      fcitx5-rime
      rime-data
      kdePackages.fcitx5-qt
      kdePackages.fcitx5-configtool
    ];
  };

  # Adding additional aliases (Not supported by HM yet...)
  home.file.".config/fontconfig/conf.d/99-alias.conf".source =
    makeln "${hm_config}/fontconfig/conf.d/99-alias.conf";

  programs.plasma.input.keyboard.numlockOnStartup = "on";
  # Forcing Layouts
  programs.plasma.configFile = {
    "kxkbrc"."Layout"."DisplayNames" = "";
    "kxkbrc"."Layout"."LayoutList" = "eu";
    "kxkbrc"."Layout"."Use" = true;
    "kxkbrc"."Layout"."VariantList" = "";
  };

  # Input method general configurations (keyboard layout and general input
  # method layout)
  home.file.".config/fcitx5".source = makeln "${hm_config}/fcitx5";

  # Specific configurations for RIME input method
  home.file."${target_rime}/default.custom.yaml".source =
    makeln "${hm_rime}/default.custom.yaml";
  home.file."${target_rime}/bopomofo_tw.custom.yaml".source =
    makeln "${hm_rime}/bopomofo_tw.custom.yaml";
  home.file."${target_rime}/bopomofo.custom.dict.yaml".source = # Custom phrases are considered sensitive
    makeln
    "${config.home.homeDirectory}/configurations/sensitive/rime/bopomofo.custom.dict.yaml";
}
