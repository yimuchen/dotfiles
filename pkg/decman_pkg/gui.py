import os
import signal
import subprocess
import tempfile

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
        deps += ["ghostty", "wezterm"]
        # For personal not taking
        deps += ["obsidian", "kate"]
        return deps

    def aur_packages(self):
        # My browser of choice
        deps = ["zen-browser-bin"]
        # For screen recording
        deps += ["showmethekey"]
        return deps

    def files(self):
        """
        The zen browser profile requires that creation of the a profiles that
        is based on the user name and a pseudo random string associated with
        the install. This will be dynamically generated, but you will have to
        run the browser once to have this be generated.
        """
        zen_base = os.path.join(user.home_path, ".zen")
        zen_install_path = os.path.join(zen_base, "installs.ini")
        zen_profile_path = os.path.join(zen_base, "profiles.ini")
        zen_pref_path = os.path.join(zen_base, "prefs.js")
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

        zen_pref_path = os.path.join(zen_base, f"{user_profile}/prefs.js")

        return {
            **zen_install.to_decman(),
            **zen_profile.to_decman(),
            **self.zen_user_preferences(zen_pref_path),
        }

    def zen_user_preferences(self, orig_path: str):
        if not os.path.exists(orig_path):
            return {}
        with open(orig_path) as f:  # Getting the orignal content
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

        # Creating a new line
        new_contents = [modify_line(line) for line in contents]
        new_contents += [
            make_line(k, v) for k, v in target_configs.items() if not create_configs[k]
        ]

        return {
            orig_path: decman.File(content="".join(new_contents), owner=user.username)
        }


class Office(decman.Module):
    def __init__(self):
        super().__init__(name="gui-office", enabled=True, version="1")

    def pacman_packages(self):
        # LibreOffice and plugins
        deps = ["libreoffice-fresh", "libreoffice-extension-texmaths"]
        # Additional items for document creation
        deps += [
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
        ]  # latex
        deps += ["typst", "tinymist"]  # typst
        # PDF browsers
        deps += ["okular", "evince", "calibre"]
        return deps

    def aur_packages(self):
        # Alternate office suite
        deps = ["wps-office"]
        # Additional packages required for markup document compiling
        deps += ["typstyle-bin"]
        # Additional
        deps += ["calibre-plugin-dedrm"]

        return deps


class Media(decman.Module):
    def __init__(self):
        super().__init__(name="gui-media", enabled=True, version="1")

    def pacman_packages(self):
        # Audio related
        deps = ["vlc", "elisa", "audacity", "kid3"]
        # Musescore is difficult...
        deps += ["musescore"]
        # Image related
        deps += ["inkscape", "gimp", "gwenview", "digikam"]
        # Additional dependencies of inkscape
        deps += ["python-tinycss2"]
        # Video related
        deps += ["kdenlive", "yt-dlp", "obs-studio", "k3b"]
        return deps

    def aur_packages(self):
        return ["wl-color-picker", "droidcam"]


class MiscTools(decman.Module):
    def __init__(self):
        super().__init__(name="gui-tools", enabled=True, version="1")

    def pacman_packages(self):
        # Alternate browsers
        deps = ["thunderbird", "signal-desktop"]
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
        return ["r2modman-bin", "proton-ge-custom-bin", "bb_launcher", "xpadneo-dkms"]

    def on_enable(self):
        decman.prg(["gpasswd", "-a", user.username, "games"])


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
