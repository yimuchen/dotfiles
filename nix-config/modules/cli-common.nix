{ config, pkgs, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_configdir = "${config.home.homeDirectory}/.config/home-manager/config";
in {
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

    # Tools to better manage git repositories
    pkgs.git
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

  # Additional configuration files for the tools listed above
  home.file = {
    # For ZSH configurations
    ".config/zsh".source = makeln "${hm_configdir}/zsh";
    ".zshrc".source = makeln "${hm_configdir}/zsh/zshrc";
    ".zshenv".source = makeln "${hm_configdir}/zsh/zshenv";
    # tmux configuration
    ".config/tmux".source = makeln "${hm_configdir}/tmux";
    # For Git configurations
    ".config/git".source = makeln "${hm_configdir}/git";
  };
}

