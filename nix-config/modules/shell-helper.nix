{ pkgs, config, ... }:
let
  # Setting up the python with various dependencies
  envpython = pkgs.python3.withPackages (ps: [
    ps.argcomplete # Autocompletion of scripts
    ps.pykeepass # Extracting data in keepassxc database
    ps.setuptools # Nonstandard packages needs setup modules
    ps.tqdm # For progress bars
    ps.wand # For imagemagick python bindings
  ]);

  pdftopng = pkgs.writeScriptBin "pdftopng.py"
    (builtins.readFile ../../pyscripts/pdftopng.py);
  keepassxc_cli = pkgs.writeScriptBin "keepassxc_cli.py"
    (builtins.readFile ../../pyscripts/keepassxc_cli.py);
  nix_check_update = pkgs.writeScriptBin "nix-check-update.py"
    (builtins.readFile ../../pyscripts/nix-check-update.py);

  root-browse = pkgs.writeShellApplication {
    name = "root-browse";
    runtimeInputs = [ pkgs.root ];
    text = # bash
      ''
        input="$1"
        if [[ "$input" == *:* ]]; then
          temp_name="/tmp/$(basename "$input")"
          scp "$input" "$temp_name"
          rootbrowse "$temp_name"
        else
          rootbrowse "$input"
        fi
      '';
    };
in {
  # Configurations for adding system helper scripts
  home.packages = [
    envpython # The system python environment
    pdftopng # PDF to PNG batch conversion script
    keepassxc_cli # Interacting with keepassxc for CLI credential interactions
    nix_check_update # Checking for nix updates upstream
    root-browse # Thin wrap around root browse
  ];
  # Additional set-up to allow for auto-completion
  programs.zsh.initExtra = # bash
    ''
      fpath=(${envpython}/lib/python3.12/site-packages/argcomplete/bash_completion.d "$fpath[@]")
      eval "$(cd ${pdftopng}/bin         && register-python-argcomplete pdftopng.py -s zsh)"
      eval "$(cd ${keepassxc_cli}/bin    && register-python-argcomplete keepassxc_cli.py -s zsh)"
      eval "$(cd ${nix_check_update}/bin && register-python-argcomplete nix-check-update.py -s zsh)"
    '';

  # Additional helper to keep track of home-manager packages
  home.file.".local/state/hm-packages".text = let
    packages = builtins.map (p: "${p.name}") config.home.packages;
    sortedUnique =
      builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  home.sessionVariables = {
    NIXCUSTOM_HM_PACKAGES =
      "${config.home.homeDirectory}/.local/state/hm-packages";
  };
}

