{ pkgs, ... }: {
  # Miscellaneous command line packages with no additional/minimal configurations.

  # For handling certificate generation
  home.packages = [ pkgs.cacert ];

  # Using NH nix helper to have a nicer update output
  programs.nh = {
    enable = true;
    # clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
  };
}
