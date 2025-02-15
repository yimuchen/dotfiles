import configparser
import os
import tempfile
from typing import Dict

import decman

__user__ = "ensc"


class UserService:
    def __init__(self, name):
        self.name
        self.install = None
        self.service = None
        self.unit = None

    @property
    def service_file(self):
        return os.path.join(
            "/home/" + __user__ + "/.config/systemd/user/" + self.name + ".service"
        )

    def to_str(self) -> str:
        config = configparser.ConfigParser()
        config["Install"] = self.install
        config["Service"] = self.service
        config["Unit"] = self.unit
        with tempfile.NamedTemporaryFile("w") as tmp:
            config.write(tmp, space_around_delimiters=False)
            tmp.flush()
            with open(tmp.name, "r") as rf:
                return rf.read()

    def to_decman(self) -> Dict[str, decman.File]:
        return {
            self.service_file: decman.File(
                content=self.to_str(), owner=__user__, group=__user__
            )
        }


class Syncthing(decman.Module):
    def __init__(self):
        super().__init__(name="syncthing", enabled=True, version="1")

    def pacman_packages(self):
        # Packages part of this module
        return ["syncthing"]

    def systemd_units(self):
        # Launching syncthing as a system service owned by the user, this way
        # Syncing can begin event before the user formally logs in
        return [f"syncthing@{__user__}.service"]


class RcbListener(decman.Module):
    def __init__(self):
        super().__init__(name="rcb_listener", enabled=True, version="1")

    def files(self):
        rcb_service = UserService("rcb_listener")
        rcb_service.install = {"WantedBy": "default.target"}
        rcb_service.service = {"ExecStart": " --port 9543"}
        rcb_service.unit = {"Description": "Remote clipboard listener service"}

        return rcb_service.to_decman()

    def systemd_user_units(self):
        return {__user__: ["rcb_listener.service"]}
