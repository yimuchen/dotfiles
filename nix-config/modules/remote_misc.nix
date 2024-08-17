{ pkgs, config, ... }:
let
  cert_cern_gen = pkgs.writeShellApplication {
    name = "cert_cern_gen";
    runtimeInputs = [ pkgs.openssl ];
    text = # bash
      ''
        if [ "$#" -ne 1 ]; then
          echo "Download your certificate at https://ca.cern.ch/ca/user/Request.aspx?template=EE2User"
          echo "Then run the command like: cert_cern_gen MY_CERTIFICATE.p12"
        else
          openssl pkcs12 -in "$1" -clcerts -nokeys -out "$HOME/.globus/usercert.pem"
          chmod 644 "$HOME/.globus/usercert.pem"
          openssl pkcs12 -in "$1" -nocerts -out "$HOME/.globus/userkey.pem"
          chmod 600 "$HOME/.globus/userkey.pem"
        fi
      '';
  };
in {
  # Miscellaneous command line packages with no additional/minimal configurations.
  home.packages = [
    pkgs.htop # For monitoring
    pkgs.tree # For directory structure dumps
    pkgs.speedtest-cli # To validate connection speeds

    # For bundling files
    pkgs.zip
    pkgs.unzip

    # For common configuration file parsing
    pkgs.jq # For JSON
    pkgs.yq-go # For YAML

    # For security file manipulation
    pkgs.openssl
    cert_cern_gen
  ];

  home.sessionVariables = {
    SSL_CERT_FILE =
      "${config.home.homeDirectory}/.nix-profile/etc/ssl/certs/ca-bundle.crt";
  };

  # Additional paths for fixing the certain executable paths for system still
  # using stand-alone home-manager instances
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";
  programs.zsh.initExtra = ''
    export PATH=$PATH:$HOME/.nix-profile/bin/
  '';
}

