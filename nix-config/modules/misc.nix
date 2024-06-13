# Miscellaneous packages with no additional configurations needed.
{ pkgs, config, ... }: {
  home.packages = [
    pkgs.libsixel # For in-termal image display
    pkgs.micromamba # For python development
    pkgs.root # For opening CERN root files
    # pkgs.pdftk # For pdf manipulation, JAVA run time requires system nix management
  ];
}

