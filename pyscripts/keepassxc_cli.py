#!/usr/bin/env python3
# Helper methods for interacting with the keepassXC

import argparse
import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Tuple

import argcomplete
import keepassxc_browser as kpb


def __make_client_idstr__() -> str:
    """
    Making the client ID string. To ensure uniqueness of the string across
    different devices and users, the user client ID use the UUID of the root
    device (should be present for all UNIX based devices), and the UID of the
    user.
    """
    devices = subprocess.check_output(["lsblk", "-l"]).decode("utf8").split("\n")
    maxmatch = 0
    device = ""
    for d in devices:
        if not d:
            continue
        devpath = d.split()[-1]
        if os.getenv("HOME").startswith(devpath) and len(devpath) > maxmatch:
            maxmatch = len(devpath)
            device = d.split()[0]
    assert device != "", "Device not found!"
    UUID = (
        subprocess.check_output(["lsblk", "-dno", "UUID", f"/dev/{device}"])
        .decode("utf8")
        .strip()
    )
    UID = os.getuid()
    return f"pyscripts_keepassxc_{UUID}_{UID}"


def __make_kpb_connection__() -> Tuple[kpb.Connection, kpb.Identity]:
    """Default settings for getting a connection"""

    # Generation of the file used to store the script association credentials.
    # Making this persistent avoids multiple reconfirm when the using this
    # script
    identity_path = os.path.join(os.getenv("HOME"), ".pyscriptkeepass")

    state_file = Path(identity_path)
    if state_file.exists():
        logging.getLogger().debug("Reading identity file")
        with state_file.open("r") as f:
            data = f.read()
        identity = kpb.Identity.unserialize(__make_client_idstr__(), data)
    else:
        logging.getLogger().info("Identify file doesn't exist! Creating new")
        identity = kpb.Identity(__make_client_idstr__())

    connection = kpb.Connection()
    connection.connect()
    connection.change_public_keys(identity)

    if not connection.test_associate(identity):
        logging.getLogger().debug("Not associated yet, associating now...")
        try:
            connection.associate(identity)
        except kpb.exceptions.ProtocolError:
            logging.getLogger().error(
                "Database is not open! Check to see that keepassXC is open and unlocked"
            )
            sys.exit(1)
        with open(identity_path, "w") as f:
            f.write(identity.serialize())
    return connection, identity


def get_credentials(protocol: str, url: str):
    """
    Getting the credential information. As of KeepassXC version 2.7.0, entries
    are only searchable via the URL. Here we are allowing the same crediential
    to be used multiple times by using the entries in the "Browser Integration"
    section.
    """
    connection, identity = __make_kpb_connection__()
    logins = connection.get_logins(identity, url=f"{protocol}://{url}")
    if len(logins) == 0:
        raise ValueError("URL entry not found")
    elif len(logins) > 1:
        raise ValueError("Multiple values found for URL!")
    else:
        return logins[0]


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


def run_kinit(sites: List[str]):
    """Running kinit command, credentials should be stored as kerberos://SITE.URL"""
    for domain in sites:
        cred = get_credentials("kerberos", domain)
        # Running the kinit command
        identity = "{}@{}".format(cred["login"], domain)
        subprocess.run(
            ["/usr/bin/kinit", "-r", "7d", identity],
            input=cred["password"],
            encoding="ascii",
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        logging.getLogger().info("Generated for identity [{0}]!".format(identity))


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


def run_voms(certificate: str, ssh_servers: List[str]):
    cred = get_credentials("cert", certificate)

    # Looping over
    for server in ssh_servers:
        try:
            logging.getLogger().info(f"Running voms-proxy-init for {server}")
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
            p.communicate(input=str.encode(cred["password"] + "\n"))
            p.wait()
        except Exception as err:
            logging.getLogger().error("Error when running voms", err)


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
    host: str,
    args: Optional[List[str]] = None,
    port: Optional[int] = None,
):
    """Starting the an RDP session using given credentials"""
    cred = get_credentials("rdp", host)
    if port is None:
        host_token = f"/v:{host}"
    else:
        host_token = f"/v:localhost:{port}"

    # Creating the command
    cmd = [
        "xfreerdp",
        host_token,
        f'/u:{cred["login"]}',
        f'/p:{cred["password"]}',
    ]  #
    cmd.extend(args)  # Splitting the additional arguments
    subprocess.run(cmd)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "keepassxc_cli",
        "Password interaction for CLI tools with keepassxc browser API",
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
    logging.getLogger().setLevel(logging.DEBUG)

    function_args = args.__dict__
    function_name = function_args.pop("subcmd")
    assert function_name in __cmd_map__.keys(), "Command not recognized!!"
    __cmd_map__[function_name](**function_args)
