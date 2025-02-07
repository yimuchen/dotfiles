{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [
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
in {
  # Configurations for adding system helper scripts
  home.packages = [ python ];
  home.sessionVariables = {
    NIX_EXEC_ROOT = "${pkgs.root}/bin/root";
    NIX_EXEC_ROOTBROWSE = "${pkgs.root}/bin/rootbrowse";
  };
}

