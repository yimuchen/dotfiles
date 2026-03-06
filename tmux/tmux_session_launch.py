#!/usr/bin/env python3
import argparse
import glob
import json
import logging
import os
import socket
import subprocess

import argcomplete
from argcomplete.completers import ChoicesCompleter

## Setting the default paths
SESSION_FILE_DIR = os.getenv(
    "TMUX_SESSION_INFO_DIR", os.path.join(os.getenv("HOME"), ".local/state/tmux/")
)

TMUX_EXEC = os.path.join(os.getenv("HOME"), ".portage/usr/bin/tmux")
if not os.path.exists(TMUX_EXEC):
    TMUX_EXEC = "tmux"
PYTHON_EXEC = os.path.join(os.getenv("HOME"), ".portage/usr/bin/python")
if not os.path.exists(PYTHON_EXEC):
    PYTHON_EXEC = "python3"


def _session_file_path(session_name):
    return os.path.join(SESSION_FILE_DIR, f"tmux.session.{session_name}.json")


def _session_tmux_path(session_name):
    return os.path.join(f"/tmp/tmux-{os.getuid()}/tmux-{session_name}")


# Setting up the logger
log = logging.getLogger("tmux_session_launch")
logging.basicConfig(
    filename=os.path.join(SESSION_FILE_DIR, "tmux.launch.log"),
    format="%(asctime)s | %(message)s",
    datefmt="%Y/%m/%d %H:%M:%S",
    encoding="utf-8",
    level=logging.DEBUG,
)


def run(session_name):
    session_file = _session_file_path(session_name)
    if not os.path.exists(session_file):
        log.info(f"Creating new session {session_name}")
        return launch_new_session(session_name, cwd=os.getcwd())

    session_info = json.load(open(session_file, "r"))
    if session_info["machine"] == socket.gethostname():
        if check_session_exist(session_name):
            log.info("Attaching to existing session")
            return attach_session(session_name)
        else:
            log.warning("Old session was not closed properly! Relaunching...")
            return launch_new_session(session_name, cwd=os.getcwd())

    # Trying to log onto a new maachine
    host = session_info["machine"]
    run_remote(session_name, host)
    pass


def _run(cmd, cwd):
    log.info("Running command:" + " ".join(cmd))
    subprocess.run(cmd, cwd=cwd)


def check_session_exist(name):
    if not os.path.exists(_session_tmux_path(name)):
        return False

    log.info(
        "Running command:"
        + " ".join([TMUX_EXEC, "-S", _session_tmux_path(name), "list-sessions"])
    )
    session_list = subprocess.run(
        [TMUX_EXEC, "-S", _session_tmux_path(name), "list-sessions"],
        capture_output=True,
    )
    if session_list.returncode != 0:
        log.warning("Error in listing session:" + session_list.stderr.decode("utf-8"))
        return False
    return any(
        x.startswith(name) for x in session_list.stdout.decode("utf-8").split("\n")
    )


def attach_session(name):
    _run(
        [TMUX_EXEC, "-S", _session_tmux_path(name), "attach-session", "-t", name],
        cwd=os.getcwd(),
    )


def launch_new_session(name, cwd):
    _run(
        [TMUX_EXEC, "-S", _session_tmux_path(name), "new-session", "-s", name],
        cwd=cwd,
    )


def run_remote(name, host):
    _run(
        [
            "ssh",
            "-o",
            "RequestTTY=yes",
            host,
            PYTHON_EXEC,
            "$HOME/.config/tmux/tmux_session_launch.py",
            name,
        ],
        cwd=os.getcwd(),
    )


def _get_sessions_list() -> list[str]:
    file_list = glob.glob(os.path.join(SESSION_FILE_DIR, "tmux.session.*.json"))
    return [json.load(open(file_path, "r"))["name"] for file_path in file_list]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "tmux_session_launch.py",
        description="Session launcher that automatically runs SSH command if required",
    )
    parser.add_argument(
        "session_name",
        nargs="*",
        default=[os.path.basename(os.getcwd())],
        help="Launching session name. Will default to current working directory if this is not specified",
        # Do not use choices directly! That will forbid arbitrary session names
    ).completer = ChoicesCompleter(_get_sessions_list())

    args = parser.parse_args()
    argcomplete.autocomplete(parser)
    assert len(args.session_name) == 1, "Only 1 session name can be specified!"
    run(args.session_name[0])
