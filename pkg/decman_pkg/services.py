import os
import socket
import stat
import xml.etree.ElementTree as ETree

import decman

from ._common import user


class Syncthing(decman.Module):
    def __init__(self):
        super().__init__(name="syncthing", enabled=True, version="1")

    def pacman_packages(self):
        # Packages part of this module
        return ["syncthing"]

    def files(self):
        self.modify_files()
        return {}

    def modify_files(self):
        # Modify the existing files if it exists
        target = os.path.join(user.home_path, ".local/state/syncthing/config.xml")
        if not os.path.exists(target):
            return

        # Modifying the address to always export 8021 for syncthing
        tree = ETree.parse("/home/ensc/.local/state/syncthing/config.xml").getroot()
        try:
            gui_config = next(b for b in tree if b.tag == "gui")
            addr_config = next(b for b in gui_config if b.tag == "address")
            addr_config.text = "127.0.0.1:8021"
        except StopIteration:
            pass

        with open(target, "wb") as f:
            f.write(ETree.tostring(tree))
        os.chmod(target, stat.S_IWUSR | stat.S_IRUSR | stat.S_IRGRP | stat.S_IWGRP)

    def systemd_units(self):
        # Launching syncthing as a system service owned by the user, this way
        # Syncing can begin event before the user formally logs in
        return [f"syncthing@{user.username}.service"]


class LanguageTool(decman.Module):
    def __init__(self):
        super().__init__(name="languagetool", enabled=True, version="1")

    def pacman_packages(self):
        return ["languagetool"]

    def systemd_units(self):
        return ["languagetool.service"]


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
        self.ollama_service["Service"] = {
            "ExecStart": "ollama serve",
            "Environment": "OLLAMA_HOST=0.0.0.0:11434",
        }
        self.ollama_service["Unit"] = {"Description": "Starting the base ollama server"}

    def pacman_packages(self):
        deps = ["ollama-docs"]
        deps += ["rust"]  # Required to build avante for nvim
        if socket.gethostname() == "enscAMDPC":
            deps += ["ollama-cuda", "nvtop"]
        else:
            deps += ["ollama"]
        return deps

    def aur_packages(self):
        deps = ["opencode-bin"]
        return deps

    def files(self):
        return self.ollama_service.to_decman()

    def systemd_user_units(self):
        return self.ollama_service.add_service()
