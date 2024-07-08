{ pkgs, config, ... }: {
  # Miscellaneous command line packages with no additional configurations.
  home.packages = [
    pkgs.libsixel # For in-terminal image display
    pkgs.micromamba # For python development
    pkgs.root # For opening CERN root files
    # pkgs.pdftk # For pdf manipulation, JAVA run time requires system nix management
    pkgs.htop # For monitoring
    pkgs.freerdp3 # For remote desktop (xrdp)
    pkgs.tree # For directory structure dumps

    # For bundling files
    pkgs.zip

    # For common configuration file parsing
    pkgs.jq # For JSON
    pkgs.yq-go # For YAML

    # For security file manipulation
    pkgs.openssl
  ];
}

