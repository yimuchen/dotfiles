"""
Specifically for the look and feel of plasma
"""

import os

import decman

from ._common import user

"""
Helper functions for generation file paths
"""


def _conf_target(path: str):
    return os.path.join(user.config_path, path)


def _frag_target(path: str):
    return os.path.join(user.config_source_dir, f"config/fragments/{path}")


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
        # For difference GUI applications
        deps += ["fcitx5-qt", "fcitx5-gtk"]
        # For configuration
        deps += ["fcitx5-configtool"]
        return deps

    def files(self):
        kwinrc = user.create_confexp(ref_path=_conf_target("kwinrc"))
        kwinrc.update_from_fragment(ref_path=_frag_target("kwinrc"))
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
        return ["arc-kde-git"]

    def files(self):
        """Theming that are likely not chancing for a long time"""
        kcminputrc = user.create_confexp(ref_path=_conf_target("kcminputrc"))
        kcminputrc.update_from_fragment(ref_path=_frag_target("kcminputrc"))

        return {
            **user.filemgr_config.create_decman_list(
                ["krunnerrc", "ktimezonedrc", "plasmarc"]
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
            ref_path=_conf_target("plasma-org.kde.plasma.desktop-appletsrc")
        )
        panels.update_from_fragment(
            ref_path=_frag_target("plasma-org.kde.plasma.desktop-appletsrc")
        )

        # Method for ensuring picking out particular shortcuts
        shortcutsrc = user.create_confexp(ref_path=_conf_target("kglobalshortcutsrc"))
        shortcutsrc.update_from_fragment(ref_path=_frag_target("kglobalshortcutsrc"))
        return {**panels.to_decman(), **shortcutsrc.to_decman()}
