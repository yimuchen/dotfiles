# Configuration for kitty

{ pkgs, config, ... }: {
  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font";
    font.size = 13;
    settings = {
      # Audio settings
      enable_audio_bell = false;

      # Tab related settings
      tab_bar_edge = "top";
      # tab_bar_margin_height = "[ 10.0 2.0 ]";
      tab_bar_style = "powerline";
      tab_bar_align = "left";
      tab_powerline_style = "slanted";
      active_tab_foreground = "#000";
      active_tab_background = "#eee";
      active_tab_font_style = "italic";
      inactive_tab_foreground = "#444";
      inactive_tab_background = "#999";
      inactive_tab_font_style = "normal";
      tab_bar_background = "#555";

      # Color related settings
      # Matching major colors to KDE breeze theme
      background_opacity = "0.8";
      background_blur = 0; # Currently not functional??
      #: black
      color0 = "#000000";
      color8 = "#767676";
      #: red
      color1 = "#ed1515";
      color9 = "#c0392b";
      #: green
      color2 = "#11d116";
      color10 = "#1cdc9a";
      #: yellow
      color3 = "#f67400";
      color11 = "#fdbc4b";
      #: blue
      color4 = "#1d99f3";
      color12 = "#3daee9";
      #: magenta
      color5 = "#9b59b6";
      color13 = "#8e44ad";
      #: cyan
      color6 = "#1abc9c";
      color14 = "#16a085";
      #: white
      color7 = "#fcfcfc";
      color15 = "#ffffff";
    };
  };
}

