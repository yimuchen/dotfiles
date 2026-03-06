#!/usr/bin/env python3
import argparse
import json
import logging
import os
import socket

## Setting the default paths
SESSION_FILE_DIR = os.getenv(
    "TMUX_SESSION_INFO_DIR", os.path.join(os.getenv("HOME"), ".local/state/tmux/")
)



# Setting up the logging instance
log = logging.getLogger("tmux_hooks")
logging.basicConfig(
    filename=os.path.join(SESSION_FILE_DIR, "tmux.hooks.log"),
    format="%(asctime)s | %(message)s",
    datefmt="%Y/%m/%d %H:%M:%S",
    encoding="utf-8",
    level=logging.DEBUG,
)


def _session_file_path(session_name):
    if not os.path.exists(SESSION_FILE_DIR):
        log.info("Creating base directory:", SESSION_FILE_DIR)
        os.mkdir(SESSION_FILE_DIR)
    return os.path.join(SESSION_FILE_DIR, f"tmux.session.{session_name}.json")


def session_created(args: argparse.Namespace):
    session_info = {
        "name": args.session_name,
        "machine": socket.gethostname(),
        "dir": os.getcwd(),
    }
    with open(_session_file_path(args.session_name), "w") as f:
        log.info(
            f"Creating new session: {args.session_name}@{session_info['machine']}:{os.getcwd()}"
        )
        json.dump(session_info, f)


def session_closed(args: argparse.Namespace):
    if os.path.exists(_session_file_path(args.session_name)):
        log.info("Closing session:", args.session_name)
        os.remove(_session_file_path(args.session_name))
    else:
        log.warning("Session file does not exist")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="tmux_hooks.py", description="Custom scripts for executing up tmux hooks"
    )
    subparsers = parser.add_subparsers(help="hooks", required=True, dest="hooks")
    session_created_parser = subparsers.add_parser("session-created")
    session_created_parser.add_argument("session_name", type=str)
    session_created_parser.set_defaults(func=session_created)
    session_closed_parser = subparsers.add_parser("session-closed")
    session_closed_parser.add_argument("session_name", type=str)
    session_closed_parser.set_defaults(func=session_closed)
    args = parser.parse_args()
    args.func(args)
