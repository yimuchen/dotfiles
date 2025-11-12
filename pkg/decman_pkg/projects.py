import decman


class hgcal_database(decman.Module):
    def __init__(self):
        super().__init__(name="hgcal_database", enabled=True, version="1")

    def pacman_packages(self) -> list[str]:
        deps = [
            "postgresql",
            "postgresql-old-upgrade",
            "typescript-language-server",
            "npm",
            "dbeaver",
        ]
        return deps

    def aur_packages(self) -> list[str]:
        # For SQL processing
        deps = ["sqlfmt-bin"]
        # For printing at Campus north
        # deps += ["cnrdrvcups-lb"]
        return deps


class hep_cpp(decman.Module):
    def __init__(self):
        super().__init__(name="hep_cpp", enabled=True, version="1")

    def pacman_packages(self) -> list[str]:
        return ["root"]
