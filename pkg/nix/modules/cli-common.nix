{ config, pkgs, ... }: {
  # Common command line packages that is useful for all systems that I will be using
  home.packages = [
    # The main shell (adding here such that this is guaranteed to be available,
    # even for remote systems)
    pkgs.zsh
    # The primary multiplexer
    pkgs.tmux

    pkgs.htop # For monitoring
    pkgs.btop
    pkgs.speedtest-cli # To validate connection speeds

    # Additional file operation packages
    pkgs.zip # Common compression tools that may be missing
    pkgs.unzip
    pkgs.jq # For JSON parsing
    pkgs.yq-go # For YAML

    # Advance file processing
    pkgs.parallel
    pkgs.lzip

    # Required for fzf terminal image browsing
    pkgs.pdftk # For PDF image manipulation
    pkgs.file # To get information about the file
    pkgs.imagemagick # For image file conversion

    # Tools to better manage git repositories
    pkgs.git # Making sure a newer version of git is included
    pkgs.lazygit
    pkgs.tokei

    # Better tools for quickly browsing files and directory structure
    pkgs.fzf
    pkgs.tree # For directory structure dumps
  ];

  home.sessionVariables = {
    # Exposing path of packages that we don't what the user to directly call
    # These are used for terminal image browsing
    NIX_EXEC_GS = "${pkgs.ghostscript}/bin/gs";
    NIX_EXEC_KITTEN = "${pkgs.kitty}/bin/kitten";
  };

}

