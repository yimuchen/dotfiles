{ config, pkgs, ... }: {
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
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/fontconfig/alias.conf";

  # Moving the input method here:
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chewing
      fcitx5-anthy
      fcitx5-chinese-addons
      kdePackages.fcitx5-qt
      kdePackages.fcitx5-configtool
    ];
  };
}
