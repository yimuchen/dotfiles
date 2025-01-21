{ pkgs, config, ... }: {
  home.packages = [
    pkgs.pdftk # For PDF image manipulation
    pkgs.file # To get information about the file
  ];

  # We will be using fzf fuzzy finder as the method for browsing images in the
  # command line
  programs.fzf = { enable = true; };
  # Additional alias for quickly browsing all images files in a directory
  programs.zsh = {
    envExtra = # bash
      ''
        # Exposing non-standard binaries to the entire zsh session (because
        # scripts needs to be able to also load the function defined here)
        export NIX_EXEC_GS=${pkgs.ghostscript}/bin/gs
        export NIX_EXEC_KITTEN=${pkgs.kitty}/bin/kitten
        # Adding the helper functions exposing the fzf item
        source $HOME/.config/zsh/termgraphics.sh
      '';
  };
}
