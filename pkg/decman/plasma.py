"""
Specifically for the look and feel of plasma
"""

import os

import decman

from ._common import user


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
        return user.filemgr_config.create_decman_list(
            [
                "fontconfig/conf.d/50-default-fonts.conf",
                "fontconfig/conf.d/99-alias.conf",
            ]
        )


class Input(decman.Module):
    def __init__(self):
        super().__init__(name="plasma-input", enabled=True, version=1)

    def pacman_packages(self):
        # Method input methods
        deps = ["fcitx5", "fcitx5-chewing", "fcitx5-anthy"]
        deps += ["fcitx5-qt", "fcitx5-gtk"]
        return deps

    def files(self):
        kwinrc = user.create_confexp(ref_path=os.path.join(user.config_path, "kwinrc"))
        kwinrc["Wayland"] = {  # Pinning the input method
            "InputMethod[$e]": "/usr/share/applications/fcitx5-wayland-launcher.desktop"
        }
        return {
            **user.filemgr_config.create_decman_list(
                ["kxkbrc", "fcitx5/profile", "fcitx5/config"]
            ),
            **kwinrc.to_decman(),
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
        kcminputrc = user.create_confexp(
            ref_path=os.path.join(user.config_path, "kcminputrc")
        )
        kcminputrc["Keyboard"] = {"NumLock": "0"}
        kcminputrc["Mouse"] = {"cursorSize": "24", "cursorTheme": "Breeze_Light"}

        return {
            **user.filemgr_config.create_decman_list(
                ["krunnerrc", "ktimezonedrc", "plasmarc", "yakuakerc"]
            ),
            **user.filemgr_share.create_decman_list(
                ["konsole/pinned.profile", "konsole/Breeze.colorscheme"]
            ),
            **kcminputrc.to_decman(),
        }


class ShortCuts(decman.Module):
    """
    Methods for pinning short cuts while leaving undetermined floating
    """

    def __init__(self):
        super().__init__(name="plasma-shortcuts", enabled=True, version="1")

    def files(self):
        shortcutsrc = user.create_confexp(
            ref_path=os.path.join(user.config_path, "kglobalshortcutsrc")
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
