{ config, pkgs, ... }: {
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-gtk pkgs.anthy pkgs.fcitx5-chewing ];
  };
}
