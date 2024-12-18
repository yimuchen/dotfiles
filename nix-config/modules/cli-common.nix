{ pkgs, ... }: {
  # Common command line packages that is useful for all systems that I will be using
  home.packages = [
    pkgs.htop # For monitoring
    pkgs.btop
    pkgs.tree # For directory structure dumps
    pkgs.speedtest-cli # To validate connection speeds

    # Additional file operation packages
    pkgs.zip
    pkgs.unzip
    pkgs.jq # For JSON
    pkgs.yq-go # For YAML

    # Advance file processing
    pkgs.parallel
  ];
}

