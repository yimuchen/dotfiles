import os

import decman
import decman_utils.common
from decman.plugins import aur, pacman

from ._common import user


def _frag_target(path: str):
    return os.path.join(user.config_source_dir, f"config/fragments/{path}")


class NiriConfig(decman.Module):
    """Additional packages for configuring tiling GUI experience"""

    def __init__(self):
        super().__init__("gui-tile")

    @pacman.packages
    def theming(self):
        deps = {"kde-gtk-config"}
        deps |= {"nwg-look"}
        return deps

    @aur.packages
    def aur_packages(self) -> set[str]:
        return {"wlr-which-key"}

    def files(self) -> dict[str, decman.File]:
        return {**self.noctalia_settings}

    @property
    def noctalia_settings_path(self) -> str:
        return os.path.join(user.state_path, "noctalia/settings.toml")

    @property
    def noctalia_settings(self) -> dict[str, decman.File]:
        settings = decman_utils.common.TOMLExp(
            user=user.username,
            group=user.username,
            target_path=self.noctalia_settings_path,
            ref_path=self.noctalia_settings_path,
        )
        settings.update_from_fragment(_frag_target("noctalia/settings.toml"))

        return settings.to_decman()
