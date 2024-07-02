{ config, pkgs, ... }: {
  # Installing additional game managers.
  # The primary steam package needs to be set up globally
  home.packages = [
    pkgs.r2modman # For dyson sphere program!
  ];

  # Find a way to automatically install and update proton-ge?
}
