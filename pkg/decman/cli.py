import os

import decman
import decman_utils

from ._common import user


class Neovim(decman.Module):
    def __init__(self):
        super().__init__(name="neovim", enabled=True, version="1")

    def pacman_packages(self):
        deps = ["neovim", "luarocks"]  # Neovim proper along with lua package manager
        # Base LSP and formatting tools for common languages
        deps += ["python-lsp-server", "ruff", "python-uv"]
        deps += ["lua-language-server", "stylua"]
        deps += ["shfmt", "bash-language-server"]
        deps += ["harper"]
        # For fuzzy finder
        deps += ["ripgrep"]
        return deps

    def aur_packages(self):
        # Additional language servers/formatters that are only available in the AUR
        deps = ["python-lsp-ruff"]
        deps += ["nixfmt"]
        return deps

    def after_update(self):
        # Installing the tools for python (mainly mdformat variants)
        python_env = os.path.join(user.home_path, ".cli-python")
        if not os.path.isdir(python_env):
            decman.sh(
                ["uv", "venv", "--system-site-packages", python_env], user=user.username
            )

        python_req = os.path.join(user.config_source_dir, "pkg/cli-python.txt")
        decman.sh(
            ["uv", "pip", "install", "--requirements", python_req],
            # user=user.username,
            env_overrides={"VIRTUAL_ENV": python_env},
        )


class ScriptsDep(decman.Module):
    """
    Adding packages required for custom scripts to process
    """

    def __init__(self):
        super().__init__(name="script-deps", enabled=True, version="1")

    def pacman_packages(self):
        deps = ["python"]  # Main language used for helper scripts
        # Additional python helper libraries
        deps += [
            "python-argcomplete",
            "python-tqdm",
            "python-wand",
            "python-requests",
            "python-numpydoc",
        ]
        # Image manipulations stuff
        deps += ["kitty", "ghostscript", "imagemagick"]
        # For password interactions in cli
        deps += ["bitwarden-cli"]
        return deps

    def after_update(self):
        decman_utils.common.install_python_symlink(
            user.home_path + "/projects/Personal/python-modules/scriptize"
        )


class CliTools(decman.Module):
    def __init__(self):
        super().__init__(name="cli-tools", enabled=True, version="1")

    def pacman_packages(self):
        # Core tools
        deps = ["git", "fzf", "parallel"]
        # Session management and monitoring
        deps += ["tmux", "htop", "speedtest-cli", "tree"]
        # Configure file parsing
        deps += ["jq", "go-yq"]
        # Additional compression formats
        deps += ["zip", "unzip", "lzip"]
        # For direct interactions with the wayland clipboard
        deps += ["wl-clipboard"]
        return deps

    def aur_packages(self):
        # For looking up items in the AUR
        deps = ["paru-bin"]
        # For python development
        deps += ["miniconda3"]
        return deps

    def files(self):
        return {
            os.path.join(user.home_path, ".condarc"): decman.File(
                content="\n".join(["auto_activate_base: false"])
            )
        }


class Symlink(decman.Module):
    """
    Generating the user-level symlinks. We will have decman to call the
    external symlinkmgr method, as not all systems will be using decman
    """

    def __init__(self):
        super().__init__(name="symlinks", enabled=True, version="1")

    def after_update(self):
        decman.prg(
            [
                os.path.join(user.config_source_dir, "bin/common/symlinkmgr"),
                "--state_dir=" + user.home_path + "/.local/state/symlinkmgr",
                os.path.join(user.config_source_dir, "config/links-cli.txt"),
            ],
            user=user.username,
            env_overrides={"HOME": user.home_path},
        )
