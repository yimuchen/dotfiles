{ pkgs, pkgs-stable, ... }: {
  # Installing additional game managers.
  # The primary steam package needs to be set up globally
  home.packages = [
    # pkgs.stream # Steam requires a global setup as it requires networking
    pkgs.r2modman # For dyson sphere program!
    pkgs.lutris # For other launchers
    pkgs-stable.shadps4
  ];

  # Find a way to automatically install and update proton-ge?
}
