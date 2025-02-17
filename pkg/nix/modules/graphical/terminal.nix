{ config, pkgs, ... }:
# Definition of terminal emulator programs. Because I'm very picky with that
# terminal experiences should be uniform, I am splitting this out as a
# separate configuration file
{
  # List of terminal programs that we will be using
  home.packages = [
    pkgs.kdePackages.yakuake
    # pkgs.kdePackages.konsole # We would probably keep this around as a backup
    pkgs.ghostty
  ];
  programs.konsole.enable = false; # Now disabling Konsole by default

  # Configuration that is set by nix-configurations (Hot key configurations)
}

