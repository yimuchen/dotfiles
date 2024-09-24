#!/usr/bin/env python3
# Helper methods for interacting with the keepassXC

import argparse
import getpass
import logging
import os
import subprocess
from typing import List, Optional, Tuple

import argcomplete
from pykeepass import PyKeePass
from pykeepass.entry import Entry

_log = logging.getLogger("keepasscx_cli.py")


def get_credentials(db: PyKeePass, protocol: str, url: str) -> Entry:
    """
    Multiple URLs can be defined in the keepassxc "browser integration"
    session. This will be stored in the  Entry.custom_properties and should be
    stored with the keys that starts with "KP2A_URL".
    """

    def is_target(x: Entry) -> bool:
        if x.url == f"{protocol}://{url}":
            return True
        for key, val in x.custom_properties.items():
            if not key.startswith("KP2A_URL"):
                continue
            if val == f"{protocol}://{url}":
                return True
        return False

    logins = [x for x in db.entries if is_target(x)]
    assert len(logins) != 0, "No entries not found"
    assert len(logins) <= 1, "Multiple values found for URL!"
    return logins[0]


def get_ssh_credentials(
    db: PyKeePass, protocol: str, url: str
) -> List[Tuple[Entry, List[str]]]:
    def find_targets(x: Entry) -> List[str]:
        ssh_targets = []
        if (
            isinstance(x.url, str)
            and x.url.startswith(f"{protocol}://")
            and x.url.endswith(f"/{url}")
        ):
            ssh_targets.append(
                x.url.replace(f"{protocol://}", "").replace(f"/{url}", "")
            )
        for key, val in x.custom_properties.items():
            if not key.startswith("KP2A_URL"):
                continue
            if val.startswith(f"{protocol}://") and val.endswith(f"/{url}"):
                ssh_targets.append(
                    val.replace(f"{protocol}://", "").replace(f"/{url}", "")
                )
        return ssh_targets

    logins = [(x, find_targets(x)) for x in db.entries]
    logins = [val for val in logins if len(val[1]) > 0]
    return logins


"""
Main process for running kinit credential generation.
"""


def add_kinit_args(parsers: argparse.ArgumentParser):
    kinit_parser = parsers.add_parser("kinit", help="Kerberose signing")
    kinit_parser.add_argument(
        "--sites",
        "-s",
        type=str,
        nargs="+",
        default=["CERN.CH", "FNAL.GOV"],
        help="Kerberose URLs to look for",
    )


def run_kinit(db: PyKeePass, sites: List[str]):
    """Running kinit command, credentials should be stored as kerberos://SITE.URL"""
    for domain in sites:
        cred = get_credentials(db, "kerberos", domain)
        # Running the kinit command
        identity = "{}@{}".format(cred.username, domain)
        subprocess.run(
            ["kinit", "-r", "7d", identity],
            input=cred.password,
            encoding="ascii",
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        _log.info("Generated local ticket for identity [{0}]!".format(identity))

    """Running kinit command for items over ssh, credentials should be stored as ssh_kerberos://<ssh_addr>/SITE.URL"""
    for domain in sites:
        cred_list = get_ssh_credentials(db, "ssh_kerberos", domain)
        for cred, target_list in cred_list:
            # Running the kinit command
            identity = "{}@{}".format(cred.username, domain)
            for ssh in target_list:
                subprocess.run(
                    ["ssh", ssh, "kinit", "-r", "7d", identity],
                    input=cred.password,
                    encoding="ascii",
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            _log.info(
                "Generated remote ticket for host [{0}] with identity [{1}]!".format(
                    ssh, identity
                )
            )


"""
VOMS certificate generation for remote ssh session
"""


def add_voms_args(parsers: argparse.ArgumentParser):
    voms_parser = parsers.add_parser("voms", help="Get grid certificate over ssh")
    voms_parser.add_argument(
        "--certificate",
        "-c",
        type=str,
        default="default_cert",
        help="Certificate identifier",
    )
    voms_parser.add_argument(
        "--ssh_servers",
        "-s",
        nargs="+",
        default=[
            "fnal-default",
            "lxplus7-default",
            "umdcms-bash",
            "cmsconnect-default",
        ],
        type=str,
        help="List of ssh servers to initialize voms proxy",
    )


def run_voms(db: PyKeePass, certificate: str, ssh_servers: List[str]):
    cred = get_credentials(db, "cert", certificate)

    # Looping over
    for server in ssh_servers:
        try:
            _log.info(f"Running voms-proxy-init for {server}")
            ssh_cmd = ["ssh", server]
            voms_cmd = [
                "voms-proxy-init",  # Main command
                "-voms",
                "cms",  # Virtual organization
                "--valid",
                "192:00",  # Valid time (8 days by default)
                "--out",
                # proxy file in single quotes for env expansion
                "'${HOME}/x509up_u${UID}'",
            ]
            cmd = " ".join(ssh_cmd + voms_cmd)
            p = subprocess.Popen(
                cmd,
                shell=True,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            p.communicate(input=str.encode(cred.password + "\n"))
            p.wait()
        except Exception as err:
            _log.error("Error when running voms", err)


"""
Running a RDP session
"""


def add_rdp_args(parsers: argparse.ArgumentParser):
    rdp_parser = parsers.add_parser("rdp", help="Staring RDP session")
    rdp_parser.add_argument(
        "--host",
        "-v",
        type=str,
        default="cerntscms.cern.ch",
        help="Where to log into the server.",
    )
    rdp_parser.add_argument(
        "--args",
        type=str,
        nargs="*",
        default=["/w:1920", "/h:1080"],
        help="""Additional options to pass to the xfreexdp instance. Default to
        set the output to a full HD screen""",
    )
    rdp_parser.add_argument(
        "--port",
        type=int,
        default=3390,
        help="""The local port that is setup for tunneling. If this value is
        not None, than it expects the host to be reachable via /v:localhost""",
    )


def run_rdp(
    db: PyKeePass,
    host: str,
    args: Optional[List[str]] = None,
    port: Optional[int] = None,
):
    """Starting an RDP session using given credentials"""
    cred = get_credentials(db, "rdp", host)
    if port is None:
        host_token = f"/v:{host}"
    else:
        host_token = f"/v:localhost:{port}"

    # Creating the command
    cmd = [
        "xfreerdp",
        host_token,
        f"/u:{cred.username}",
        f"/p:{cred.password}",
    ]  #
    cmd.extend(args)  # Splitting the additional arguments
    subprocess.run(cmd)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "keepassxc_cli",
        """
        Password interaction for CLI tools with keepassxc browser API. Set up
        as path to the database using the environment variable "KPXC_DATABASE".
        """,
    )
    subparsers = parser.add_subparsers(dest="subcmd")
    add_kinit_args(subparsers)
    add_voms_args(subparsers)
    add_rdp_args(subparsers)
    __cmd_map__ = {
        "kinit": run_kinit,
        "voms": run_voms,
        "rdp": run_rdp,
    }
    argcomplete.autocomplete(parser)
    args = parser.parse_args()
    if not args.subcmd:
        parser.print_help()
        raise ValueError("Command is required")

    logging.basicConfig()
    _log.setLevel(logging.DEBUG)

    assert (
        "KPXC_DATABASE" in os.environ
    ), "Define environment variable 'KPXC_DATABASE' as a path to data base"
    dbpath = os.environ["KPXC_DATABASE"]

    function_args = {
        "db": PyKeePass(dbpath, getpass.getpass(prompt=f"Password for [{dbpath}]: ")),
        **args.__dict__,
    }
    function_name = function_args.pop("subcmd")
    assert function_name in __cmd_map__.keys(), "Command not recognized!!"
    __cmd_map__[function_name](**function_args)
