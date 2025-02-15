"""
Specifically for the look and feel of plasma
"""

import configparser
import os
import tempfile
from typing import Dict

import decman

_user_ = "ensc"


def _make_config_direct(path: str) -> Dict[str, decman.File]:
    """
    Generating entry for performing a direct copy of the files to the
    $HOME/.config directory. This is good for files that you don't want to
    change without modifying install dependencies.
    """
    return {
        os.path.join(decman.config_path(_user_), path): decman.File(
            source_file=os.path.join(decman.dec_source(_user_), "config/" + path)
        )
    }


def _make_share_direct(path: str) -> Dict[str, decman.File]:
    """
    Generating entry for performing a direct copy of the file to the
    $HOME/.local/share directory. This is good for files that you don't want to
    change without modifying install dependencies.
    """
    return {
        os.path.join(decman.share_path(_user_), path): decman.File(
            source_file=os.path.join(decman.dec_source(_user_), "share/" + path)
        )
    }


def config_path(path):
    return os.path.join(decman.config_path(_user_), path)


class ConfExp(configparser.ConfigParser):
    """
    Configuration parser that can be used for a partial update of a
    configuration file. This entry most useful when you want to leave certain
    entries float but pin specific entries of interest.
    """

    def __init__(self, path: str):
        super().__init__(interpolation=None)
        self.read(path)
        self.target_path = path

    def optionxform(self, optionstr):  # Disable case casing
        return optionstr

    def to_str(self) -> str:
        with tempfile.NamedTemporaryFile("w") as tmp:
            self.write(tmp, space_around_delimiters=False)
            tmp.flush()
            with open(tmp.name, "r") as rf:
                return rf.read()

    def to_decman(self) -> Dict[str, decman.File]:
        return {
            self.target_path: decman.File(
                content=self.to_str(), owner=_user_, group=_user_
            )
        }


class Fonts(decman.Module):
    def __init__(self):
        super().__init__(name="plasma-font", enabled=True, version="1")

    def pacman_packages(self):
        # Baseline sans/serif fonts
        deps = ["noto-fonts", "noto-fonts-cjk"]
        # Baseline serif fonts
        deps += ["ttf-libertinus"]
        # Baseline monospace fonts
        deps += ["ttf-jetbrains-mono-nerd"]
        # Miscellaneous fonts
        deps += ["otf-firamono-nerd"]
        return deps

    def aur_packages(self):
        return ["ttf-tw", "ttf-ms-fonts"]

    def files(self):
        return {
            **_make_config_direct("fontconfig/conf.d/50-default-fonts.conf"),
            **_make_config_direct("fontconfig/conf.d/99-alias.conf"),
        }


class Input(decman.Module):
    def __init__(self):
        super().__init__(name="plasma-input", enabled=True, version=1)

    def pacman_packages(self):
        # Method input methods
        deps = ["fcitx5", "fcitx5-chewing", "fcitx5-anthy"]
        deps += ["fcitx5-qt", "fcitx5-gtk"]
        return deps

    def files(self):
        kwinrc = ConfExp(config_path("kwinrc"))
        kwinrc["Wayland"] = {  # Pinning the input method
            "InputMethod[$e]": "/usr/share/applications/fcitx5-wayland-launcher.desktop"
        }
        return {
            **_make_config_direct("kxkbrc"),
            **kwinrc.to_decman(),
            **_make_config_direct("fcitx5/profile"),  # Pins ordering of input methods
            **_make_config_direct("fcitx5/config"),  # Pinning hot key items
        }


class Themes(decman.Module):
    def __init__(self):
        super().__init__(name="plasma-themes", enabled=True, version=1)

    def pacman_packages(self):
        """Packages required for themes to work"""
        return ["papirus-icon-theme", "fcitx5-breeze"]

    def aur_packages(self):
        return ["arc-kde"]

    def files(self):
        """Theming that are likely not chancing for a long time"""

        kcminputrc = ConfExp(config_path("kcminputrc"))
        kcminputrc["Keyboard"] = {"NumLock": "0"}
        kcminputrc["Mouse"] = {"cursorSize": "24", "cursorTheme": "Adwaita"}

        return {
            **_make_config_direct("krunnerrc"),
            **_make_config_direct("ktimezonedrc"),
            **_make_config_direct("plasmarc"),
            **kcminputrc.to_decman(),
            # Pinning a yakuake styling
            **_make_config_direct("yakuakerc"),
            **_make_share_direct("konsole/pinned.profile"),
            **_make_share_direct("konsole/Breeze.colorscheme"),
        }


class Applications(decman.Module):
    """
    Methods for generating application files to launch programs with custom
    configurations.
    """

    def __init__(self):
        super().__init__(name="plasma-application", enabled=True, version="1")

    def files(self):
        firefox_profile = ConfExp(
            os.path.join(decman.home_path(_user_), ".mozilla/firefox/profiles.ini")
        )
        firefox_profile["Profile0"] = {
            "Default": "1",
            "IsRelative": "1",
            "Name": "casual",
            "Path": "casual",
        }
        firefox_profile["Profile2"] = {
            "Default": "0",
            "IsRelative": "1",
            "Name": "work",
            "Path": "work",
        }

        return {
            **firefox_profile.to_decman(),
            **_make_share_direct("applications/firefox.work.desktop"),
            **_make_share_direct("applications/firefox.default.desktop"),
        }


class ShortCuts(decman.Module):
    """
    Methods for pinning short cuts while leaving undetermined floating
    """

    def __init__(self):
        super().__init__(name="plasma-shortcuts", enabled=True, version="1")

    def files(self):
        shortcutsrc = ConfExp(config_path("kglobalshortcutsrc"))
        # Odd notation for getting the various entries to work?
        shortcutsrc["services][com.mitchellh.ghostty.desktop"] = {"_launch": "Meta+T"}
        # Explicitly disabling console for now
        shortcutsrc["services][org.kde.konsole.desktop"] = {"_launch": "none"}
        shortcutsrc["services][firefox.default.desktop"] = {"_launch": "Meta+B"}
        shortcutsrc["services][firefox.work.desktop"] = {"_launch": "Meta+Shift+B"}
        shortcutsrc["services][org.kde.krunner.desktop"] = {"_launch": "Meta"}

        # Yakuake is just different from everyone else:
        shortcutsrc["yakuake"] = {
            "_k_friendly_name": "Yakuake",
            "toggle-window-state": "Meta+X,F12,Open/Retract Yakuake",
        }

        # Modifying shortcuts for quickly cycling between window
        shortcutsrc["kwin"]["Expose"] = (
            "Meta+Q,Ctrl+F9,Toggle Present Windows (Current desktop)"
        )
        shortcutsrc["kwin"]["Walk Through Windows"] = (
            "Meta+Tab,Alt+Tab,Walk Through Windows"
        )
        return shortcutsrc.to_decman()
