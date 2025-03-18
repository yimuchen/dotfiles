import hashlib
import os

import decman
import decman_utils

from ._common import user


class Core(decman.Module):
    """Essential functionalities - browsing and terminal access"""

    def __init__(self):
        super().__init__(name="gui-core", enabled=True, version="1")

    def pacman_packages(self):
        # For online interactions
        deps = ["bitwarden"]
        # For personal information management
        deps += ["thunderbird", "korganizer"]
        # Terminal of preference
        deps += ["ghostty", "yakuake"]
        return deps

    def aur_packages(self):
        # My browser of choice
        deps = ["zen-browser-bin"]
        return deps

    def files(self):
        """
        The zen browser profile requires that creation of the a profiles that
        is based on the user name and a pseudo random string associated with
        the install. This will be dynamically generated, but you will have to run the .
        """
        zen_install_path = os.path.join(user.home_path, ".zen/installs.ini")
        zen_profile_path = os.path.join(user.home_path, ".zen/profiles.ini")
        ## How is this generate???
        user_hash = "15B76BAA26BA15E7"
        user_profile = f"{user.username}Profile"
        zen_install = decman_utils.ConfExp(
            target_path=zen_install_path, user=user.username
        )
        zen_install[user_hash] = {"Default": f"{user.username}Profile", "Locked": "1"}
        zen_profile = decman_utils.ConfExp(
            target_path=zen_profile_path, user=user.username
        )
        zen_profile["Profile0"] = {
            "Name": user_profile,
            "IsRelative": "1",
            "Path": user_profile,
            "Default": "1",
        }
        zen_profile["General"] = {"StartWithLastProfile": "1", "Version": "2"}
        zen_profile[f"Install{user_hash}"] = {"Default": user_profile, "Locked": "1"}
        return {**zen_install.to_decman(), **zen_profile.to_decman()}


class Office(decman.Module):
    def __init__(self):
        super().__init__(name="gui-office", enabled=True, version="1")

    def pacman_packages(self):
        # LibreOffice and plugins
        deps = ["libreoffice-fresh", "libreoffice-extension-texmaths"]
        # PDF browsers
        deps += ["okular", "evince"]
        return deps

    def aur_packages(self):
        # Additional LibreOffice plugins in the AUR
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
        deps = ["steam", "lutris"]
        # Optional dependencies for lutris
        deps += ["wine", "python-protobuf"]
        return deps

    def aur_packages(self):
        return ["r2modman-bin", "proton-ge-custom-bin"]


class Symlink(decman.Module):
    """
    Generating the user-level symlinks. We will have decman to call the
    external symlinkmgr method, as not all systems will be using decman
    """

    def __init__(self):
        super().__init__(name="symlinks", enabled=True, version="1")

    def after_update(self):
        decman.prg(
            [
                os.path.join(user.config_source_dir, "bin/common/symlinkmgr"),
                "--state_dir=" + user.home_path + "/.local/state/symlinkmgr",
                os.path.join(user.config_source_dir, "config/links-graphical.txt"),
            ],
            user=user.username,
            env_overrides={"HOME": user.home_path},
        )
