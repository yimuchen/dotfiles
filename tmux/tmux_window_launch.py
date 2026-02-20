#!/usr/bin/env python3
# Helper script for creating tmux windows via a configuration JSON file
import argparse
import json
import os
import subprocess
from dataclasses import dataclass
from typing import Dict


@dataclass
class ConfigEntry:
    title: str = None
    cmd: str = None
    disable: bool = False

    def respawn_tmux_cmd(self, target):
        default_shell = (
            subprocess.check_output(["tmux", "show-options", "-g", "default-shell"])
            .decode("utf-8")
            .split()[1]
        )
        return [
            "tmux",
            "respawn-pane",
            "-t",
            f"{target}.0",
            "-k",
            f"\"{default_shell} --login -c '{self.cmd}'\"",
        ]


def parse_config_json(
    config: Dict[str, ConfigEntry], json_path: str
) -> Dict[str, ConfigEntry]:
    if not os.path.exists(json_path):
        return config

    try:
        json_config = json.load(open(json_path, "r"))
        for k, v in json_config.items():
            config[k] = ConfigEntry(**v)
    except Exception as err:
        pass
    return config


def switch_window(
    session_name: str, window_idx: str, config: Dict[str, ConfigEntry]
) -> None:
    tconf = config.get(window_idx, None)
    target = f"{session_name}:{window_idx}"
    if (
        subprocess.run(
            ["tmux", "has-session", "-t", target], stderr=subprocess.DEVNULL
        ).returncode
        != 0
    ):
        if not (tconf and tconf.disable):
            subprocess.run(["tmux", "new-window", "-t", target])
        if tconf and tconf.cmd:  # Specific command if this is executed
            subprocess.run(" ".join(tconf.respawn_tmux_cmd(target)), shell=True)

    if window_idx in config and config[window_idx].title:
        subprocess.run(
            ["tmux", "rename-window", "-t", target, config[window_idx].title]
        )
    # Move to that window
    subprocess.run(["tmux", "select-window", "-t", window_idx])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog=__file__, description="Launcher for named tmux window"
    )
    parser.add_argument(
        "--user_config",
        type=str,
        default=os.path.join(
            os.getenv("$XDG_CONFIG_HOME", os.path.join(os.getenv("HOME"), ".config")),
            "tmux/windows_layout.json",
        ),
        help="Path to global configurations files",
    )
    parser.add_argument(
        "--dir_config",
        type=str,
        default=os.path.join(os.getcwd(), ".tmux_windows_layout.json"),
        help="Path to local configuration files",
    )
    parser.add_argument(
        "session_name",
        type=str,
        help="Tmux session that we are working with",
    )
    parser.add_argument(
        "window_index",
        type=str,
        help="tmux window index that we are attempting to switch to",
    )
    args = parser.parse_args()

    # Getting the configuration
    config = parse_config_json({}, args.user_config)
    config = parse_config_json(config, args.dir_config)
    # Running the window status
    switch_window(args.session_name, args.window_index, config)
