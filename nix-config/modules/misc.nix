# Miscellaneous packages with no additional configurations needed.
{ pkgs, config, ... }: {
  home.packages = [ pkgs.libsixel pkgs.micromamba pkgs.root pkgs.tmux ];

  # Link to the major configuration path
  home.file.".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/tmux.conf";
}

