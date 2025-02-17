{ config, pkgs, ... }: {
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

  # Forcing Layouts
  programs.plasma.input.keyboard = {
    numlockOnStartup = "on";
    layouts = [{ layout = "eu"; }];
  };
}
