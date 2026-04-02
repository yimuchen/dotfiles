#!/usr/bin/env python3
import configparser
import glob
import json
import os
import subprocess
from typing import Dict, List, Tuple

CACHE_FILE = os.path.join(os.environ["HOME"], ".cache/fuzzel_picker.json")

PINNED_APPLICATIONS = {
    "Terminal (Ghostty)": "/usr/share/applications/com.mitchellh.ghostty.desktop",
    "Browser (Zen Browser)": "/usr/share/applications/zen.desktop",
    "Mail (Thunderbird)": "/usr/share/applications/org.mozilla.Thunderbird.desktop",
    "Player (Elisa)": "/usr/share/applications/org.kde.elisa.desktop",
}


def _list_all_applications() -> Dict[str, str]:
    file_list = (
        glob.glob("/usr/share/applications/*.desktop")
        + glob.glob("/usr/local/share/appplications/*.destop")
        + glob.glob(os.getenv("HOME") + "/.local/share/applications/*.desktop")
    )
    count_cache = json.load(open(CACHE_FILE, "r")) if os.path.exists(CACHE_FILE) else {}
    # Ordering according to count
    file_list = sorted(file_list, key=lambda x: count_cache.get(x, 0), reverse=True)

    ret_dict = {}
    for file in file_list:
        parser = configparser.ConfigParser()
        parser.read(file)
        if parser["Desktop Entry"]["Type"] == "Application":
            ret_dict[parser["Desktop Entry"]["Name"]] = file
    return ret_dict


def make_fuzzel_dmenu() -> List[Tuple[str, List[str], str]]:
    """
    The first string would be used for the fuzzel dmenu (joined by new-line).
    The second would be the tuple that is used to execute the various items.
    The third is the application ID associated with the choice. This will be
    used for reordering applications based on most called
    """
    # Keeping the list of open windows for reference
    open_windows = json.loads(
        subprocess.check_output(["niri", "msg", "--json", "windows"]).decode("utf-8")
    )
    app_list = _list_all_applications()

    # Making the display message in fuzzel
    def _menu_str(prefix, name, desktop):
        parser = configparser.ConfigParser()
        parser.read(desktop)
        if "Icon" in parser["Desktop Entry"]:
            return f"{prefix} {name}\u0000icon\u001f{parser['Desktop Entry']['Icon']}"
        else:
            return f"{prefix} {name}"

    def _focus_cmd(id):
        return ["niri", "msg", "action", "focus-window", "--id", str(id)]

    def _launch_cmd(desktop):
        return ["gio", "launch", desktop]

    # The actual return object
    ret_list: List[Tuple[str, List[str], str]] = []

    # Processing pinned applications
    for name, desktop in PINNED_APPLICATIONS.items():
        m_str = _menu_str("=", name, desktop)
        try:
            existing = next(
                w
                for w in open_windows
                if os.path.basename(desktop) == w["app_id"] + ".desktop"
            )
            open_windows.pop(open_windows.index(existing))
            ret_list.append((m_str, _focus_cmd(existing["id"]), "pinned"))
        except StopIteration:
            ret_list.append((m_str, _launch_cmd(desktop), "pinned"))

    # Processing existing windows
    for win in open_windows:
        try:
            name, desktop = next(
                (name, desktop)
                for name, desktop in app_list.items()
                if os.path.basename(desktop) == win["app_id"] + ".desktop"
            )
            ret_list.append(
                (_menu_str("*", name, desktop), _focus_cmd(win["id"]), desktop)
            )
        except StopIteration:
            pass

    # For all other desktop application, create a launch call
    for name, desktop in app_list.items():
        ret_list.append((_menu_str("+", name, desktop), _launch_cmd(desktop), desktop))

    return ret_list


def run_fuzzel():
    fuzzel_entries = make_fuzzel_dmenu()

    fuzzel_process = subprocess.Popen(
        ["fuzzel", "--dmenu", "--index", "--no-run-if-empty", "--no-sort"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )
    fuzzel_process.stdin.write(
        "\n".join([entry[0] for entry in fuzzel_entries]).encode("utf-8")
    )
    fuzzel_process.stdin.close()

    choice = fuzzel_process.stdout.read().decode("utf-8")
    if not choice:
        return

    choice = int(choice)
    count_cache = json.load(open(CACHE_FILE, "r")) if os.path.exists(CACHE_FILE) else {}
    subprocess.run(fuzzel_entries[choice][1])
    cache_key = fuzzel_entries[choice][2]
    count_cache[cache_key] = count_cache.get(cache_key, 0) + 1
    json.dump(count_cache, open(CACHE_FILE, "w"))


if __name__ == "__main__":
    run_fuzzel()
