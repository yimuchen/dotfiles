{ config, pkgs, ... }: {
  # Miscelleneous packages that needs to be installed but does not require
  # additional configurations
  home.packages = [
    # Terminal interaction Notice that KDE specific configurations will be
    # placed in the plasma.nix configurations 
    pkgs.kdePackages.yakuake
    pkgs.kdePackages.konsole
    # For interacting with key data base
    pkgs.keepassxc
    # For video and audio playback
    pkgs.vlc
    pkgs.kdePackages.elisa
    # For image display
    pkgs.kdePackages.okular
    pkgs.kdePackages.gwenview
    # For image/audio/video editing
    pkgs.kdePackages.kdenlive
    pkgs.audacity
    pkgs.musescore
    pkgs.gimp
    pkgs.obs-studio
    pkgs.digikam
    # Work related
    pkgs.kicad
    pkgs.freecad
    pkgs.virt-manager
  ];
}
