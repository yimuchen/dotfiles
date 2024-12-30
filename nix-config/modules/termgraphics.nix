{ pkgs, config, ... }:
let
  _pdf2png = pkgs.writeShellApplication {
    name = "pdf2png";
    text = # bash
      ''
        ${pkgs.ghostscript}/bin/gs -sDEVICE=pngalpha -o %stdout -r144 -dBATCH -dNOPAUSE -dQUIET "$1"
      '';
  };

  _icat = pkgs.writeShellApplication {
    name = "_icat";
    text = # bash
      ''
        ${pkgs.kitty}/bin/kitten icat "$@"
      '';
  };

in {
  home.packages = [
    _icat # Making a thin alias of kitty terminals icat
    _pdf2png # Making default method for casting PDF to png images
    pkgs.pdftk # For PDF image manipulation
    pkgs.file # To get information about the file
  ];

  # We will be using fzf fuzzy finder as the method for browsing images in the
  # command line
  programs.fzf = { enable = true; };
  # Additional alias for quickly browsing all images files in a directory
  programs.zsh = {
    initExtra = # bash
      ''
        export PATH=$PATH:$HOME/.config/zsh/termgraphics
      '';
    shellAliases = {
      "imgbrowse" =
        "find . -name '*.pdf' -o -name '*.png' -o -name '*.jpg' | fzf --preview 'fzf-img-preview {}'";
    };
  };
}
