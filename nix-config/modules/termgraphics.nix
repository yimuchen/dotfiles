{ pkgs, config, ... }:
let
  pdf2sixel = pkgs.writeShellApplication {
    name = "pdf2sixel";
    runtimeInputs = [ pkgs.ghostscript pkgs.libsixel ];
    text = # bash
      ''
        for file_path in $@
          gs -sDEVICE=pngalpha -o %stdout -r144 -dBATCH -dNOPAUSE -dQUIET $file_path |
          img2sixel --height=800px -
      '';
  };

in {
  # Additional tools for performing graphical tools in the terminal
  programs.zsh.shellAliases = {
    "img2sixel" = "${pkgs.libsixel}/bin/img2sixel --height=800px";
  };
  home.packages = [ pdf2sixel ];
}
