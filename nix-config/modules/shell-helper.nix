{ pkgs, config, ... }:
let
  # Setting up the python with various dependencies
  envpython = pkgs.python3.withPackages (ps: [
    ps.argcomplete # Autocompletion of scripts
    ps.setuptools # Nonstandard packages needs setup modules
    ps.tqdm # For progress bars
    ps.wand # For imagemagick python bindings
  ]);

  pdftopng = pkgs.writeScriptBin "pdftopng.py"
    (builtins.readFile ../../pyscripts/pdftopng.py);
  bw_run = pkgs.writeScriptBin "bw_run.py"
    (builtins.readFile ../../pyscripts/bw_run.py);
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
          rootbrowse --web=off "$temp_name"
        else
          rootbrowse --web=off "$input"
        fi
      '';
  };
in {
  # Configurations for adding system helper scripts
  home.packages = [
    envpython # The system python environment
    pdftopng # PDF to PNG batch conversion script
    bw_run # Interacting with keepassxc for CLI credential interactions
    nix_check_update # Checking for nix updates upstream
    root-browse # Thin wrap around root browse
  ];
  # Additional set-up to allow for auto-completion
  programs.zsh.initExtra = # bash
    ''
      fpath=(${envpython}/lib/python3.12/site-packages/argcomplete/bash_completion.d "$fpath[@]")
      eval "$(cd ${pdftopng}/bin         && register-python-argcomplete pdftopng.py         -s zsh)"
      eval "$(cd ${bw_run}/bin           && register-python-argcomplete bw_run.py           -s zsh)"
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

