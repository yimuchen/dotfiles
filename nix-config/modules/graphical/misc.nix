{ config, pkgs, ... }:{
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
    pkgs.evince
    pkgs.kdePackages.gwenview
    # For image/audio/video editing
    pkgs.kdePackages.kdenlive
    pkgs.yt-dlp
    pkgs.audacity
    pkgs.musescore
    pkgs.gimp
    pkgs.obs-studio
    pkgs.digikam
    pkgs.inkscape
    # Document editing - NOTE: do not use QT version of libreoffice! This
    # breaks the UI for whatever reason...
    pkgs.libreoffice
    # pkgs.onlyoffice-bin
    pkgs.wpsoffice
    # Work related
    # (pkgs.callPackage ../../pkgs/kicad.nix { })
    pkgs.kicad # Circuit/PCB design. NOTE: Has issue upgrading to python3.12?
    # pkgs.kikit # Additional PCB panneling
    pkgs.freecad # 3D object modelling NOTE: Has issue with QT python binding?
    pkgs.virt-manager
    pkgs.freerdp3 # Remote desktop - RDP
    pkgs.tigervnc # Remote desktop - VNC
    pkgs.thunderbird # Not migrating to NIX management for now.
    pkgs.zoom-us
    pkgs.chromium
  ];
}
