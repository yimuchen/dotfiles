# Miscellaneous packages with no additional configurations needed.
{ pkgs, config, ... }: {
  home.packages = [
    pkgs.libsixel
    pkgs.micromamba
    pkgs.root
  ];
}

