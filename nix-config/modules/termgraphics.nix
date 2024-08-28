{ pkgs, config, ... }:
let
  pdf2png = pkgs.writeShellApplication {
    name = "pdf2sixel";
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
            pdf2sixel "$file_path" | ${pkgs.libsixel}/bin/img2sixel "$wargs" "$hargs"
          else
            ${pkgs.libsixel}/bin/img2sixel "$file_path" "$wargs" "$hargs"
          fi
        done
      '';
  };

in {
  home.packages = [
    img2sixel # Overwritten version of img2sixel
    pkgs.pdftk # For PDF image manipulation
  ];
}
