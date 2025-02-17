import decman

from ._common import _user_


class Syncthing(decman.Module):
    def __init__(self):
        super().__init__(name="syncthing", enabled=True, version="1")

    def pacman_packages(self):
        # Packages part of this module
        return ["syncthing"]

    def systemd_units(self):
        # Launching syncthing as a system service owned by the user, this way
        # Syncing can begin event before the user formally logs in
        return [f"syncthing@{_user_}.service"]


class RcbListener(decman.Module):
    def __init__(self):
        super().__init__(name="rcb_listener", enabled=True, version="1")
        self.rcb_service = decman.UserService(user=_user_, name="rcb_listener")
        self.rcb_service["Install"] = {"WantedBy": "default.target"}
        self.rcb_service["Service"] = {
            "ExecStart": f"{decman.dec_source(_user_)}/bin/local/rcb_listener.py --port 9543"
        }
        self.rcb_service["Unit"] = {"Description": "Remote clipboard listener service"}

    def files(self):
        return self.rcb_service.to_decman()

    def systemd_user_units(self):
        return {_user_: [self.rcb_service.service_name]}
