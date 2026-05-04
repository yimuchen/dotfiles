#!/usr/bin/env python3
import argparse
import json
import os
import subprocess

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "Checking if any instance of the application already exists, focus if it does, spawn a new instance otherwise."
    )
    parser.add_argument("application", type=str)
    args = parser.parse_args()
    windows = json.loads(
        subprocess.check_output(["niri", "msg", "--json", "windows"]).decode("utf8")
    )
    try:
        x = next(window for window in windows if window["app_id"] == args.application)
        print("Focus existing instance")
        subprocess.run(["niri", "msg", "action", "focus-window", "--id", str(x["id"])])
    except StopIteration:
        desktop_path = os.path.join(
            "/usr/share/applications/", f"{args.application}.desktop"
        )
        if not os.path.exists(desktop_path):
            raise NotImplementedError(f"Desktop path [{desktop_path}] does not exist!")
        subprocess.run(["gio", "launch", desktop_path])
