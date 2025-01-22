{ pkgs, config, ... }:
let
  # Setting up the python with various dependencies
  envpython = pkgs.python3.withPackages (ps: [
    # Items required for the scripts found in pyscripts directory
    ps.argcomplete # Autocompletion of scripts
    ps.setuptools # Nonstandard packages needs setup modules
    ps.tqdm # For progress bars
    ps.wand # For imagemagick python bindings
    ps.psutil # For generating unique ID everytime we boot
    # Additional items for waydroid
    ps.requests
    ps.inquirerpy
  ]);

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
  hm_binextra = "${config.home.homeDirectory}/.config/home-manager/bin/local/";
in {
  # Configurations for adding system helper scripts
  home.packages = [
    envpython # The system python environment
    root-browse # Thin wrap around root browse
  ];
  # Additional set-up to allow for auto-completion
  programs.zsh = {
    envExtra = # bash
      ''
        # This needs to be available in all items
        export PATH="$PATH:${hm_binextra}"
      '';
    initExtra = # bash
      ''
        fpath=(${envpython}/lib/python3.12/site-packages/argcomplete/bash_completion.d "$fpath[@]")
        eval "$(cd ${hm_binextra} && register-python-argcomplete pdftopng.py -s zsh)"
        eval "$(cd ${hm_binextra} && register-python-argcomplete bw_run.py -s zsh)"
      '';
  };

  # Additional helper to keep track of home-manager packages
  home.file.".local/state/hm-packages".text = let
    packages = builtins.map (p: "${p.name}") config.home.packages;
    sortedUnique =
      builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  # Creating a service to starting the rcb listener aon user login
  systemd.user.services.rcb_listener = {
    Unit = { Description = "Remote clipboard listener service"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = { ExecStart = "${hm_binextra}/rcb_listener.py --port 9543"; };
  };

  home.sessionVariables = {
    NIXCUSTOM_HM_PACKAGES =
      "${config.home.homeDirectory}/.local/state/hm-packages";
  };
}

