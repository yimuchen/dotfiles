"""
Specifically for the look and feel of plasma
"""

import os

import decman

from ._common import _make_config_direct, _make_share_direct, _user_


def config_path(path):
    return os.path.join(decman.config_path(_user_), path)


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
        kwinrc = decman.ConfExp(
            ref_path=config_path("kwinrc"), target_path=config_path("kwinrc")
        )
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

        kcminputrc = decman.ConfExp(
            ref_path=config_path("kcminputrc"), target_path=config_path("kcminputrc")
        )
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
        ff_ppath = os.path.join(
            decman.home_path(_user_), ".mozilla/firefox/profiles.ini"
        )
        firefox_profile = decman.ConfExp(ref_path=ff_ppath, target_path=ff_ppath)
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
        shortcutsrc = decman.ConfExp(
            ref_path=config_path("kglobalshortcutsrc"),
            target_path=config_path("kglobalshortcutsrc"),
        )
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
