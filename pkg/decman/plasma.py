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
        # Modifying panels to always include specific items
        panels = user.create_confexp(
            ref_path=os.path.join(
                user.config_path, "plasma-org.kde.plasma.desktop-appletsrc"
            )
        )
        application_list = [
            "applications:com.mitchellh.ghostty.desktop",
            "applications:zen.desktop",
            "applications:org.mozilla.Thunderbird.desktop",
            "applications:org.kde.dolphin.desktop",
            "applications:org.kde.korganizer.desktop",
            "applications:systemsettings.desktop",
            "file:///usr/share/applications/libreoffice-startcenter.desktop",
            "applications:bitwarden.desktop",
            "applications:virt-manager.desktop",
            "applications:org.kicad.kicad.desktop",
            "applications:org.musescore.MuseScore.desktop",
        ]
        for section in panels.sections():
            if "launchers" in panels[section].keys():
                panels[section]["launchers"] = ",".join(application_list)

        # Method for ensuring picking out particular shortcuts
        shortcutsrc = user.create_confexp(
            ref_path=os.path.join(user.config_path, "kglobalshortcutsrc")
        )
        # Items additonal binding for stuff that is on the main panel
        shortcutsrc["plasmashell"]["activate task manager entry 1"] = (
            "Meta+T\tMeta+1,Meta+1,Activate Task Manager Entry 1"
        )
        shortcutsrc["plasmashell"]["activate task manager entry 2"] = (
            "Meta+B\tMeta+2,Meta+2,Activate Task Manager Entry 2"
        )
        shortcutsrc["plasmashell"]["activate task manager entry 3"] = (
            "Meta+B\tMeta+3,Meta+3,Activate Task Manager Entry 1"
        )

        # Explicitly disabling console for now
        shortcutsrc["services][org.kde.konsole.desktop"] = {"_launch": "none"}
        # Setting K-runner hotkey to juet meta
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
        return {**panels.to_decman(), **shortcutsrc.to_decman()}
