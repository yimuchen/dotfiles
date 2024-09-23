{ pkgs, config, ... }:
let
  # Additional configurations that is required for remote nix installations.
  # This is typically to ensure that my useful set of helper utilities are
  # properly installed, and will properly function when running nix as a
  # non-privileged users.
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

    # For handling certificate generation
    pkgs.cacert
    cert_cern_gen
  ];

  home.sessionVariables = {
    # Additional variables to use
    SSL_CERT_FILE =
      "${config.home.homeDirectory}/.nix-profile/etc/ssl/certs/ca-bundle.crt";
  };

  # Have tmux start the shell with the custom zsh shell. We are assuming that
  # tmux will only be used within a nix shell
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";

  # Additional fixes for ZSH to remove system-level configurations
  programs.zsh = {
    # Fixing the paths of the home-manager profile to be properly exposed
    initExtra = # bash
      ''
        export PATH=$HOME/.nix-profile/bin/:$PATH
      '';
    # Ensuring system autocomplete paths to be removed
    initExtraBeforeCompInit = # bash
      ''
        fpath=()
        for profile in $HOME/.nix-profile; do
          fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
        done
      '';
    # Additional aliases for slightly nicer monitoring on multi user systems
    shellAliases = {
      "htop" = "htop --user";
    };
  };
  # Additional fixes for ssh to ensure git does not use system-level ssh
  # configurations
  programs.git.extraConfig = { core = { sshComm = "ssh -F ~/.ssh/config"; }; };
}
