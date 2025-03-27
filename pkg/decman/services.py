import socket

import decman

from ._common import user


class Syncthing(decman.Module):
    def __init__(self):
        super().__init__(name="syncthing", enabled=True, version="1")

    def pacman_packages(self):
        # Packages part of this module
        return ["syncthing"]

    def systemd_units(self):
        # Launching syncthing as a system service owned by the user, this way
        # Syncing can begin event before the user formally logs in
        return [f"syncthing@{user.username}.service"]


class RcbListener(decman.Module):
    def __init__(self):
        super().__init__(name="rcb_listener", enabled=True, version="1")
        self.rcb_service = user.create_service(service_name="rcb_listener.service")
        self.rcb_service["Install"] = {"WantedBy": "default.target"}
        self.rcb_service["Service"] = {
            "ExecStart": f"{user.config_source_dir}/bin/local/rcb_listener.py --port 9543"
        }
        self.rcb_service["Unit"] = {"Description": "Remote clipboard listener service"}

    def files(self):
        return self.rcb_service.to_decman()

    def systemd_user_units(self):
        return self.rcb_service.add_service()


class LLMService(decman.Module):
    def __init__(self):
        super().__init__(name="llm_service", enabled=True, version="1")
        self.ollama_service = user.create_service(service_name="ollama.service")
        self.ollama_service["Install"] = {"WantedBy": "default.target"}
        self.ollama_service["Service"] = {"ExecStart": "ollama serve"}
        self.ollama_service["Unit"] = {"Description": "Starting the base ollama server"}

    def pacman_packages(self):
        deps = ["ollama-docs"]
        if socket.gethostname() == "enscAMDPC":
            deps += ["ollama-cuda"]
        else:
            deps += ["ollama"]
        return deps

    def files(self):
        return self.ollama_service.to_decman()

    def systemd_user_units(self):
        return self.ollama_service.add_service()
