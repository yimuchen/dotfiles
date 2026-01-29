import decman
from decman.plugins import aur, flatpak, pacman


class hgcal_database(decman.Module):
    def __init__(self):
        super().__init__("hgcal_database")

    @pacman.packages
    def pacman_packages(self) -> set[str]:
        deps = {
            "postgresql",
            "postgresql-old-upgrade",
            "typescript-language-server",
            "npm",
            "dbeaver",
        }
        return deps

    @aur.packages
    def aur_packages(self) -> set[str]:
        # For SQL processing
        deps = {"sqlfmt-bin"}
        # For printing at Campus north
        # deps += ["cnrdrvcups-lb"]
        return deps

    @flatpak.packages
    def flatpak_packages(self) -> set[str]:
        return {"com.ultimaker.cura"}


class hep_cpp(decman.Module):
    def __init__(self):
        super().__init__(name="hep_cpp")

    @pacman.packages
    def pacman_packages(self) -> list[str]:
        return {"root"}
