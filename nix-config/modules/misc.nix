# Miscellaneous packages
{ pkgs, config, ... }: {
  home.packages = [
    pkgs.micromamba
    pkgs.libsixel
  ];
}

