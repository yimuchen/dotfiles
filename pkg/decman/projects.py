import decman


class hgcal_database(decman.Module):
    def __init__(self):
        super().__init__(name="hgcal_database", enabled=True, version="1")

    def pacman_packages(self) -> list[str]:
        deps = ["postgresql", "typescript-language-server", "npm", "dbeaver"]
        return deps

    def aur_packages(self) -> list[str]:
        return ["sqlfmt-bin"]
