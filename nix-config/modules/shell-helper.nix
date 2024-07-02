# Configurations for adding python developement environments and system helper
# scripts
#
{ pkgs, config, ... }: {
  home.packages = [
    # Our main packages all require python
    (pkgs.python3.withPackages (ps: [
      # Additional items required to run the various helper scripts For
      # autocompletion
      ps.argcomplete
      # For extracting data in keepassxc database
      ps.pykeepass
    ]))

    # For PDF conversion
    pkgs.imagemagick

    # PDF conversion script
    (pkgs.writeScriptBin "pdftopng.py"
      (builtins.readFile ../../pyscripts/pdftopng.py))
    # Interactions with PDF
    (pkgs.writeScriptBin "keepassxc_cli.py"
      (builtins.readFile ../../pyscripts/keepassxc_cli.py))
    # Method for calling the obtaining package version informations 
    (pkgs.writeScriptBin "nix-check-update.py"
      (builtins.readFile ../../pyscripts/nix-check-update.py))
  ];

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

