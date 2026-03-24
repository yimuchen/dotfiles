import os
import socket
import stat
import xml.etree.ElementTree as ETree
from typing import Dict

import decman
from decman.plugins import aur, pacman, systemd

from ._common import user


class Syncthing(decman.Module):
    def __init__(self):
        super().__init__("syncthing")

    @pacman.packages
    def pacman_packages(self):
        return {"syncthing"}

    def files(self):
        return {**self.syncthing_config}

    @property
    def syncthing_gui_port(self) -> int:
        return 8021

    @property
    def syncthing_gui_addr(self) -> str:
        return (
            "127.0.0.1" if "Hetzner" not in socket.gethostname() else "0.0.0.0"
        )  # Allow remote access

    @property
    def syncthing_config(self) -> Dict[str, decman.File]:
        # Modify the existing files if it exists
        target = os.path.join(user.home_path, ".local/state/syncthing/config.xml")
        if not os.path.exists(target):
            {}

        tree = ETree.parse(target).getroot()
        try:
            gui_config = next(b for b in tree if b.tag == "gui")
            addr_config = next(b for b in gui_config if b.tag == "address")
            addr_config.text = f"{self.syncthing_gui_addr}:{self.syncthing_gui_port}"
        except StopIteration:
            pass
        return {
            target: decman.File(
                content=ETree.tostring(tree).decode("utf-8"),
                owner=user.username,
                group=user.username,
            )
        }

    @systemd.user_units
    def systemd_units(self):
        return {user.username: {"syncthing.service"}}


class LanguageTool(decman.Module):
    def __init__(self):
        super().__init__("languagetool")

    @pacman.packages
    def pacman_packages(self):
        return {"languagetool"}

    @systemd.units
    def systemd_units(self):
        return {"languagetool.service"}


class RcbListener(decman.Module):
    def __init__(self):
        super().__init__("rcb_listener")
        self.rcb_service = user.create_service(service_name="rcb_listener.service")
        self.rcb_service["Install"] = {"WantedBy": "default.target"}
        self.rcb_service["Service"] = {
            "ExecStart": f"{user.config_source_dir}/bin/local/rcb_listener.py --port 9543"
        }
        self.rcb_service["Unit"] = {"Description": "Remote clipboard listener service"}

    def files(self):
        return self.rcb_service.to_decman()

    @systemd.user_units
    def systemd_user_units(self):
        return self.rcb_service.to_decman_unit()


class LLMService(decman.Module):
    def __init__(self):
        super().__init__("llm_service")
        self.ollama_service = user.create_service(service_name="ollama.service")
        self.ollama_service["Install"] = {"WantedBy": "default.target"}
        self.ollama_service["Service"] = {
            "ExecStart": "ollama serve",
            "Environment": "OLLAMA_HOST=0.0.0.0:11434",
        }
        self.ollama_service["Unit"] = {"Description": "Starting the base ollama server"}

    @pacman.packages
    def pacman_packages(self):
        deps = {"ollama-docs"}
        deps |= {"rust"}  # Required to build avante for nvim
        if socket.gethostname() == "enscAMDPC":
            deps |= {"ollama-cuda", "nvtop"}
        else:
            deps |= {"ollama"}
        return deps

    @aur.packages
    def aur_packages(self) -> set[str]:
        deps = {"opencode-bin"}
        return set()

    def files(self):
        return self.ollama_service.to_decman()

    @systemd.user_units
    def systemd_user_units(self):
        return self.ollama_service.to_decman_unit()
