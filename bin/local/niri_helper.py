#!/usr/bin/env python3
import json
import logging
import os
import subprocess
from typing import Any, Dict

import argcomplete
import scriptize

scriptizer = scriptize.Scriptizer(
    prog=os.path.basename(__file__),
    description="""
        Helper methods for quickly managing windows with niri.
    """,
)

"""
Common helpers methods
"""


def _get_niri(*args) -> Dict[str, Any]:
    cmd = ["niri", "msg", "--json"] + [str(x) for x in args]
    return json.loads(subprocess.check_output(cmd).decode("utf-8"))


def niri_windows():
    return _get_niri("windows")


def _set_niri(*args):
    return subprocess.run(["niri", "msg", "action"] + [str(x) for x in args])


@scriptizer.register_function
def quick_split(direction: scriptize.Choice["left", "right"]):
    windows = niri_windows()
    focused = next(w for w in windows if w["is_focused"])
    offset = 1 if direction == "left" else -1
    try:
        secondary = next(
            w
            for w in windows
            if w["workspace_id"] == focused["workspace_id"]
            and w["layout"]["pos_in_scrolling_layout"][0]
            == focused["layout"]["pos_in_scrolling_layout"][0] + offset
        )
        _set_niri("set-window-width", "--id", focused["id"], "50%")
        _set_niri("set-window-width", "--id", secondary["id"], "50%")
        _set_niri("focus-window", "--id", secondary["id"])
        _set_niri("focus-window", "--id", focused["id"])
    except StopIteration:
        pass


@scriptizer.register_function
def launch_single(application: str):
    """
    Helper function to either focus on an existing window, or launch a new
    instance if it doesn't already exist

    Parameters
    ==========

    application: str
    Target application, the string should match the name used for the desktop file, which 
    is what is used for the default 'app_id' in niri.
    """
    windows = niri_windows()
    try:
        x = next(window for window in windows if window["app_id"] == application)
        print("Focus existing instance")
        subprocess.run(["niri", "msg", "action", "focus-window", "--id", str(x["id"])])
    except StopIteration:
        desktop_path = os.path.join(
            "/usr/share/applications/", f"{application}.desktop"
        )
        if not os.path.exists(desktop_path):
            raise NotImplementedError(f"Desktop path [{desktop_path}] does not exist!")
        subprocess.run(["gio", "launch", desktop_path])


if __name__ == "__main__":
    logging.basicConfig()
    scriptizer.log.setLevel(logging.DEBUG)
    argcomplete.autocomplete(scriptizer.main_parser)
    scriptizer.run_interactive()
