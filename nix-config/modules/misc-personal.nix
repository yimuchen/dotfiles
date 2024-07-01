{ pkgs, config, ... }: {
  # Miscellaneous command line tools for personal use
  home.packages = [
    pkgs.openssl # To install browser certificate
  ];
}
