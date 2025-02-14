{ pkgs, pkgs-stable, ... }: {
  # Miscellaneous packages that needs to be installed but does not require
  # additional configurations. KDE packages that require additional
  # configurations will be placed in plasma.nix
  home.packages = [
    pkgs.wl-clipboard # For getting the command line output into wayland clipboard
    pkgs.showmethekey # For screen casting
    # For interacting with password data base
    pkgs-stable.bitwarden-cli
    pkgs.bitwarden-desktop
    # For keyboard configuration
    pkgs.wootility
    # For video and audio playback
    pkgs.vlc
    pkgs.kdePackages.elisa
    pkgs.kdePackages.k3b
    # For image display
    pkgs.kdePackages.okular
    pkgs.evince
    pkgs.kdePackages.gwenview
    # For image/audio/video editing
    pkgs.kdePackages.kdenlive
    pkgs.kdePackages.kdeconnect-kde
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
    pkgs.wpsoffice
    # Work related
    pkgs-stable.kicad # Circuit/PCB design. NOTE: Has issue upgrading to python3.12?
    pkgs-stable.kikit # Additional PCB panneling
    pkgs.freecad # 3D object modelling NOTE: Has issue with QT python binding?
    pkgs.virt-manager
    pkgs.freerdp3 # Remote desktop - RDP
    pkgs.tigervnc # Remote desktop - VNC
    pkgs.thunderbird # Not migrating to NIX management for now.
    pkgs.zoom-us
    pkgs.ventoy-full # For bootable USB configurations
    # Alternate browser
    pkgs.ungoogled-chromium
    # pkgs.ladybird
  ];
}
