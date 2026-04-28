import os
from typing import Dict

import decman
import decman_utils
from decman.plugins import aur, pacman, systemd

from ._common import user


class Core(decman.Module):
    """Essential functionalities - browsing and terminal access"""

    def __init__(self):
        super().__init__(name="gui-user-core")

    @pacman.packages
    def pacman_packages(self) -> set[str]:
        # For online interactions
        deps = {"bitwarden"}
        # For personal information management
        deps |= {"thunderbird", "korganizer"}
        # Terminal of preference
        deps |= {"ghostty", "wezterm"}
        # For personal not taking
        deps |= {"obsidian", "kate"}
        # For screen casting
        deps |= {"showmethekey"}
        # For getting items from phone
        deps |= {"kdeconnect"}
        return deps

    @aur.packages
    def aur_packages(self):
        # My browser of choice
        deps = {"zen-browser-bin"}
        return deps

    @systemd.user_units
    def ghostty_service(self) -> dict[str, set]:
        return {user.username: {"app-com.mitchellh.ghostty.service"}}

    def files(self):
        """
        The zen browser profile requires that creation of the a profiles that
        is based on the user name and a pseudo random string associated with
        the install. This will be dynamically generated, but you will have to
        run the browser once to have this be generated.
        """
        return {
            **self.zen_install_file,
            **self.zen_profile_file,
            **self.zen_user_preferences,
        }

    """
    Zen browser configuration
    """

    @property
    def zen_base(self) -> str:
        return os.path.join(user.home_path, ".zen")

    @property
    def zen_user_hash(self) -> str:  # Magic number??
        return "15B76BAA26BA15E7"

    @property
    def zen_user_profile(self) -> str:
        return f"{user.username}Profile"

    @property
    def zen_install_file(self) -> Dict[str, decman.File]:
        zen_install = decman_utils.ConfExp(
            target_path=os.path.join(self.zen_base, "installs.ini"), user=user.username
        )
        zen_install[self.zen_user_hash] = {
            "Default": f"{user.username}Profile",
            "Locked": "1",
        }
        return zen_install.to_decman()

    @property
    def zen_profile_file(self) -> Dict[str, decman.File]:
        zen_profile = decman_utils.ConfExp(
            target_path=os.path.join(self.zen_base, "profiles.ini"), user=user.username
        )
        zen_profile["Profile0"] = {
            "Name": self.zen_user_profile,
            "IsRelative": "1",
            "Path": self.zen_user_profile,
            "Default": "1",
        }
        zen_profile["General"] = {"StartWithLastProfile": "1", "Version": "2"}
        zen_profile[f"Install{self.zen_user_hash}"] = {
            "Default": self.zen_user_profile,
            "Locked": "1",
        }
        return zen_profile.to_decman()

    @property
    def zen_user_preferences(self) -> Dict[str, decman.File]:
        zen_pref_path = os.path.join(self.zen_base, f"{self.zen_user_profile}/prefs.js")
        if not os.path.exists(zen_pref_path):
            return {}
        with open(zen_pref_path) as f:  # Getting the original content
            contents = f.readlines()
        # Creating a new contents
        target_configs = {
            "pdfjs.defaultZoomValue": "page-fit",
            "signon.rememberSignons": False,
        }
        create_configs = {
            k: False for k in target_configs
        }  # Checking if items are checked

        def make_line(key, value):
            if type(value) is float or type(value) is int:
                return f'user_pref("{key}", {value});\n'
            if type(value) is bool:
                pval = "true" if value else "false"
                return f'user_pref("{key}", {pval});\n'
            return f'user_pref("{key}", "{value}");\n'

        def modify_line(line):
            if not line.startswith("user_pref"):
                return line
            for k, v in target_configs.items():
                if line.startswith(f'user_pref("{k}"'):
                    create_configs[k] = True
                    return make_line(k, v)
            return line

        new_contents = [modify_line(line) for line in contents]
        new_contents += [
            make_line(k, v) for k, v in target_configs.items() if not create_configs[k]
        ]
        return {
            zen_pref_path: decman.File(
                content="".join(new_contents), owner=user.username
            )
        }


class Office(decman.Module):
    def __init__(self):
        super().__init__("gui-office")

    @pacman.packages
    def pacman_packages(self):
        # LibreOffice and plugins
        deps = {"libreoffice-fresh", "libreoffice-extension-texmaths"}
        # Additional items for document creation
        deps |= {
            "texlive-bin",
            "texlive-binextra",
            "texlive-fontsextra",
            "texlive-fontsrecommended",
            "texlive-fontutils",
            "texlive-mathscience",
            "texlive-bibtexextra",
            "texlive-pictures",
            "texlive-latex",
            "texlive-latexextra",
            "texlive-latexrecommended",
            "texlive-xetex",
            "texlive-langchinese",
            "texlive-langenglish",
            "texlive-langgerman",
            "texlab",
        }  # latex
        deps |= {"typst", "tinymist", "typstyle"}  # typst
        # PDF browsers
        deps |= {"okular", "evince", "calibre"}
        return deps

    @aur.packages
    def aur_packages(self):
        # Alternate office suite
        deps = {"wps-office"}
        # Additional
        deps |= {"calibre-plugin-dedrm"}

        return deps


class Media(decman.Module):
    def __init__(self):
        super().__init__("gui-media")

    @pacman.packages
    def audio_packages(self):
        return {"vlc", "elisa", "audacity", "kid3", "musescore"}

    @pacman.packages
    def image_packages(self):
        return {"inkscape", "gimp", "gwenview", "digikam"}

    @pacman.packages
    def video_packages(self):
        return {"kdenlive", "yt-dlp", "obs-studio", "k3b"}

    @aur.packages
    def aur_packages(self):
        return {"wl-color-picker", "droidcam"}

    def files(self) -> Dict[str, decman.File]:
        musescore_config = decman_utils.ConfExp(
            target_path=os.path.join(user.config_path, "MuseScore/MuseScore4.ini"),
            ref_path=os.path.join(user.config_path, "MuseScore/MuseScore4.ini"),
            user=user.username,
        )
        musescore_config.update_from_fragment(
            os.path.join(
                user.config_source_dir, "config/fragments/MuseScore/MuseScore4.ini"
            )
        )
        return musescore_config.to_decman()


class MiscTools(decman.Module):
    def __init__(self):
        super().__init__("gui-tools")

    @pacman.packages
    def pacman_packages(self):
        return {"thunderbird", "signal-desktop"}

    @pacman.packages
    def cad_packages(self):
        return {
            "freecad",
            "kicad",
            "kicad-library",
            "kicad-library-3d",
            "python-kikit",
        }

    @pacman.packages
    def virtual_remotes(self):
        return {"virt-manager", "tigervnc", "freerdp"}

    @aur.packages
    def aur_packages(self):
        # Non-free software
        deps = {"ungoogled-chromium-bin", "vscodium-bin"}
        # For boot USB management
        deps |= {"ventoy-bin"}
        return deps


class Gaming(decman.Module):
    def __init__(self):
        super().__init__("gui-game")

    @pacman.packages
    def pacman_packages(self) -> set[str]:
        return {"steam"}

    @pacman.packages
    def lutris_packages(self) -> set[str]:
        return {"lutris", "wine", "python-protobuf"}

    @aur.packages
    def aur_packages(self):
        return {
            "r2modman-bin",
            "proton-ge-custom-bin",
            "bb_launcher",
            "xpadneo-dkms",
        }

    def on_enable(self, store):
        decman.prg(["gpasswd", "-a", user.username, "games"])


class Symlink(decman.Module):
    """
    Generating the user-level symlinks. We will have decman to call the
    external symlinkmgr method, as not all systems will be using decman
    """

    def __init__(self):
        super().__init__("symlinks")

    def after_update(self, store):
        decman.prg(
            [
                os.path.join(user.config_source_dir, "bin/common/symlinkmgr"),
                "--state_dir=" + user.home_path + "/.local/state/symlinkmgr",
                os.path.join(user.config_source_dir, "config/links-graphical.txt"),
            ],
            user=user.username,
            env_overrides={"HOME": user.home_path},
        )
