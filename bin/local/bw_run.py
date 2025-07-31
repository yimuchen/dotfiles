#!/usr/bin/env python3
import getpass
import json
import logging
import os
import subprocess
import sys
import tempfile
import time
from typing import Any, Callable, Dict, List, Optional

import argcomplete
import scriptize

scriptizer = scriptize.Scriptizer(
    prog=os.path.basename(__file__),
    description="""
        Using the credentials stored in a bitwarden vault to perform predefined
        operations. This script assumes that you have access to the `bw`
        command, and that you have already logged in to a vault of interest
        with the `bw login` method. """,
)

"""
General functions for selecting credentials from bw CLI method. These will not
be exposed for user interaction
"""


def obtain_bw_items(item_filter: Optional[Callable] = None) -> List[Dict]:
    """
    Getting the list of vault items in the default BitWarden vault. You can
    provide an additional function to filter the items of interest.
    """
    bw_process = subprocess.Popen(
        ["bw", "list", "items"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = bw_process.communicate(
        input=str.encode(getpass.getpass("Master password for Bitwarden vault:") + "\n")
    )
    try:
        items_list = json.loads(stdout)
    except:
        scriptizer.log.error(
            "Bitwarden did not return a valid response, make sure you provided the correct master password"
        )
        sys.exit(1)
    if item_filter is not None:
        items_list = [x for x in items_list if item_filter(x)]
    return items_list


def protocol_filter(protocol: str | List[str]):
    """
    Creating the method to filter items that contain a particular protocol in their URI
    """
    if isinstance(protocol, str):
        protocol = [protocol]

    def _f(item: Dict[str, Any]):
        if "login" not in item:
            return False
        return any(
            any([True if (x["uri"].startswith(p + "://")) else False for p in protocol])
            for x in item["login"]["uris"]
        )

    return _f


def get_protocols(item: Dict[str, Any], protocol: str):
    """
    For a BitWarden vault item, return the URIs corresponding to the protocol
    of interest.
    """
    return [
        x["uri"].replace(protocol + "://", "")
        for x in item["login"]["uris"]
        if x["uri"].startswith(protocol + "://")
    ]


@scriptizer.register_function
def kinit():
    """
    Creating the kerberos ticket

    Generating the kerberos ticket using the credentials stored in BitWarden
    vaults. The credentials that will be used should contain the following
    information in the format of a URI:

        - kerberos://SERVER.URL: In this case, we will run the command kinit
          username@SERVER.URL, where the SERVER.URL will be determined by the
          URI, and the user and corresponding password will be extracted from
          the credentials.
        - ssh_kerberos://SSH_HOST/SERVER.URL: In this case will run the same
          kinit command except on the SSH_HOST specified in the vault item URI.
          The SSH_HOST should be able to complete without user input, i.e. no password login.
    """
    kinit_items = obtain_bw_items(protocol_filter(["kerberos", "ssh_kerberos"]))
    for item in [x for x in kinit_items if protocol_filter("kerberos")(x)]:
        username = item["login"]["username"]
        for server in get_protocols(item, "kerberos"):
            subprocess.run(
                ["kinit", "-r", "7d", f"{username}@{server}"],
                input=item["login"]["password"],
                encoding="ascii",
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            scriptizer.log.info(f"Created kerberos ticket for {username}@{server}")

    for item in [x for x in kinit_items if protocol_filter("ssh_kerberos")(x)]:
        username = item["login"]["username"]
        for target in get_protocols(item, "ssh_kerberos"):
            ssh, server = target.split("/")
            subprocess.run(
                ["ssh", ssh, "kinit", "-r", "7d", f"{username}@{server}"],
                input=item["login"]["password"],
                encoding="ascii",
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            scriptizer.log.info(
                f"Created kerberos ticket for {username}@{server} at ssh host {ssh}"
            )


@scriptizer.register_function
def voms():
    """
    Activating VOMS certificates on ssh hosts

    The item containing the VOMS certificate credential should be listed with
    URI entries in the format of "cert_voms://SSH_SERVER", where the
    "SSH_SERVER" is the ssh host that should be handled. Theses ssh hosts
    should set such that no user input is needed.
    """
    # Looping over
    for item in obtain_bw_items(protocol_filter(["cert_voms"])):
        for ssh_host in get_protocols(item, "cert_voms"):
            try:
                scriptizer.log.info(
                    f"Running voms-proxy-init using certificate [{item['name']}] at ssh host [{ssh_host}]"
                )
                ssh_cmd = ["ssh", ssh_host]
                voms_cmd = [
                    "voms-proxy-init",  # Main command
                    "-voms",
                    "cms",  # Virtual organization
                    "--valid",
                    "192:00",  # Valid time (8 days by default)
                    "--out",
                    # proxy file in single quotes for env expansion to be handled by the server-side
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
                p.communicate(input=str.encode(item["login"]["password"] + "\n"))
                p.wait()
            except Exception as err:
                scriptizer.log.error("Error when running voms", err)


@scriptizer.register_function
def copypass():
    """
    Browsing through the login credentials, copying the password to thw wayland clipboard
    """
    logins = obtain_bw_items(lambda x: "login" in x)

    def make_display(login):
        return {
            "name": login["name"],
            "username": login["login"]["username"],
            "identifiers": [x["uri"] for x in login["login"]["uris"]],
        }

    select = None
    with tempfile.NamedTemporaryFile("w") as temp:
        temp.write(json.dumps([make_display(login) for login in logins]))

        fzf_process = subprocess.Popen(
            [
                "fzf",
                "--reverse",
                "--preview",
                "jq '.[] | select(.name == \"{}\")' " + temp.name,
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
        fzf_process.stdin.write(
            "\n".join([x["name"] for x in logins]).encode("utf8")
        )  # Writing opens
        fzf_process.stdin.close()
        select = fzf_process.stdout.read().splitlines()
        if len(select) == 0:
            return  # Early exit with no error
        select = select[0].decode("utf8")

    login = [x for x in logins if x["name"] == select][0]
    copy_process = subprocess.Popen("wl-copy", stdin=subprocess.PIPE)
    copy_process.stdin.write(login["login"]["password"].encode("utf8"))
    copy_process.stdin.close()
    try:
        for t in range(20, 0, -1):
            print(
                f"\rCopied password of [{select}], clearing clipboard in {t} seconds...",
                end="",
            )
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:  # Ensuring that wl-copy is always used
        print("Clearing.")
        subprocess.Popen(["wl-copy", "--clear"])
        subprocess.Popen(
            [
                "gdbus",
                "call",
                "--session",
                "--dest",
                "org.kde.klipper",
                "--object-path",
                "/klipper",
                "--method",
                "org.kde.klipper.klipper.clearClipboardHistory",
            ]
        )


if __name__ == "__main__":
    logging.basicConfig()
    scriptizer.log.setLevel(logging.DEBUG)
    argcomplete.autocomplete(scriptizer.main_parser)
    scriptizer.run_interactive()
