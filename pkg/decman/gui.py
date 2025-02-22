import decman


class Core(decman.Module):
    """Essential functionalities - browsing and terminal access"""

    def __init__(self):
        super().__init__(name="gui-core", enabled=True, version="1")

    def pacman_packages(self):
        return [
            "firefox",
            "ghostty",
            "yakuake",
            "bitwarden",
            "thunderbird",
            "korganizer",
        ]


class Office(decman.Module):
    def __init__(self):
        super().__init__(name="gui-office", enabled=True, version="1")

    def pacman_packages(self):
        # Libreoffice and plugins
        deps = ["libreoffice-fresh", "libreoffice-extension-texmaths"]
        # PDF browsers
        deps += ["okular", "evince"]
        return deps

    def aur_packages(self):
        # Additional libreoffice plugins in the AUR
        deps = ["libreoffice-extension-languagetool"]
        # Alternate office suite
        deps += ["wps-office-bin"]
        return deps


class Media(decman.Module):
    def __init__(self):
        super().__init__(name="gui-media", enabled=True, version="1")

    def pacman_packages(self):
        # Audio related
        deps = ["vlc", "elisa", "audacity", "musescore"]
        # Image related
        deps += ["inkscape", "gimp", "gwenview", "digikam"]
        # Additional dependencies of inkscape
        deps += ["python-tinycss2"]
        # Video related
        deps += ["kdenlive", "yt-dlp", "obs-studio", "k3b"]
        return deps


class MiscTools(decman.Module):
    def __init__(self):
        super().__init__(name="gui-tools", enabled=True, version="1")

    def pacman_packages(self):
        # Alternate browsers
        deps = ["thunderbird"]
        # Related to hardware design
        deps += [
            "freecad",
            "kicad",
            "kicad-library",
            "kicad-library-3d",
            "python-kikit",
        ]
        # Virtual machine and remote access
        deps += ["virt-manager", "tigervnc", "freerdp"]
        return deps

    def aur_packages(self):
        # Non-free software
        deps = ["ungoogled-chromium-bin", "vscodium-bin"]
        # For boot USB management
        deps += ["ventoy-bin"]
        return deps


class Gaming(decman.Module):
    def __init__(self):
        super().__init__(name="gui-game", enabled=True, version="1")

    def pacman_packages(self):
        return ["steam", "lutris"]

    def aur_packages(self):
        return ["r2modman-bin", "proton-ge-custom-bin"]
