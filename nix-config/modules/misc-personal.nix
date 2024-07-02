{ pkgs, config, ... }: {
  # Miscellaneous command line tools for personal use
  home.packages = [
    pkgs.openssl # To install browser certificate
    pkgs.cacert
  ];
  home.sessionVariables = {
    "SSL_CERT_FILE" =
      "${config.home.homeDirectory}/.nix-profile/etc/ssl/certs/ca-bundle.crt";
  };
}
