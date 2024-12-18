{ pkgs, config, ... }:
let
  pdf2png = pkgs.writeShellApplication {
    name = "pdf2png";
    runtimeInputs = [ pkgs.ghostscript pkgs.libsixel ];
    text = # bash
      ''
        gs -sDEVICE=pngalpha -o %stdout -r144 -dBATCH -dNOPAUSE -dQUIET "$1"
      '';
  };

  img2sixel = pkgs.writeShellApplication {
    name = "img2sixel";
    runtimeInputs = [ pdf2png pkgs.libsixel ];
    text = # bash
      ''
        # Multiplicative factor should be close to the font size in pixels
        max_width=$(($(tput cols)*7))
        max_height=$(($(tput lines)*14))
        if [ "$max_width" -lt "$max_height" ]; then
          wargs="--width=$max_width"
          hargs="--height=auto"
        else
          wargs="--width=auto"
          hargs="--height=$max_height"
        fi
        for file_path in "$@" ; do
          if [[ "$file_path" == *.pdf ]]; then
            pdf2png "$file_path" | ${pkgs.libsixel}/bin/img2sixel "$wargs" "$hargs"
          else
            ${pkgs.libsixel}/bin/img2sixel "$file_path" "$wargs" "$hargs"
          fi
        done
      '';
  };

  fzf-img-preview = pkgs.writeShellApplication {
    name = "fzf-img-preview";
    runtimeInputs = [ pdf2png pkgs.libsixel ];
    text = # bash
      ''
        # Basic method for parsing the inputs
        file="$1"
        type="$(file --dereference --mime -- "$file")"
        realpath="$(realpath "$file")"

        if [[ ! "$type" =~ image/ ]]; then
          if [[ "$type" =~ "application/pdf" ]]; then
            echo "Full path: [$realpath]"
            pdf2png "$file" | ${pkgs.libsixel}/bin/img2sixel "--width=$((FZF_PREVIEW_COLUMNS*10))" "--height=auto"
            exit
          elif [[ "$type" =~ =binary ]]; then
            echo "Omitting binary file preview"
            echo "Full path: [$realpath]"
            file "$1"
            exit
          fi
          cat "$file"
          exit
        fi

        echo "Full path: [$realpath]"
        ${pkgs.libsixel}/bin/img2sixel "--width=$((FZF_PREVIEW_COLUMNS*10))" "--height=auto" "$file"
      '';
  };

in {
  home.packages = [
    img2sixel # Overwritten version of img2sixel
    pkgs.pdftk # For PDF image manipulation
    pkgs.file # To get information about the file
    fzf-img-preview
  ];

  # We will be using fzf fuzzy finder as the method for browsing images in the
  # command line
  programs.fzf = { enable = true; };
  # Additional alias for quickly browsing all images files in a directory
  programs.zsh.shellAliases = {
    "imgbrowse" =
      "find . -name '*.pdf' -o -name '*.png' -o -name '*.jpg' | fzf --preview 'fzf-img-preview {}'";
  };
}
