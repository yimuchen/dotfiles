import os
from typing import Dict

import decman

_user_ = "ensc"
# String representing the base directory of user configurations
_dec_source = os.path.realpath(os.path.basename(__file__) + "/../../")


def _make_config_direct(path: str) -> Dict[str, decman.File]:
    """
    Generating entry for performing a direct copy of the files to the
    $HOME/.config directory. This is good for files that you don't want to
    change without modifying install dependencies.
    """
    return {
        os.path.join(decman.config_path(_user_), path): decman.File(
            source_file=os.path.join(_dec_source, "config/" + path)
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
            source_file=os.path.join(_dec_source, "share/" + path)
        )
    }
