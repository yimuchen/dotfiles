import os

import decman
import decman_utils

from ._common import user


class Neovim(decman.Module):
    def __init__(self):
        super().__init__(name="neovim", enabled=True, version="1")

    def pacman_packages(self):
        deps = ["neovim", "luarocks"]  # Neovim along with lua package manager
        deps += ["tree-sitter", "tree-sitter-cli"]  # Tree-sitter stuff
        # Base LSP and formatting tools for common languages
        deps += ["python-lsp-server", "ruff", "python-uv"]
        deps += ["lua-language-server", "stylua"]
        deps += ["shfmt", "bash-language-server"]
        deps += ["harper"]
        # For fuzzy finder
        deps += ["ripgrep", "fzf"]
        return deps

    def aur_packages(self):
        # Additional language servers/formatters that are only available in the AUR
        # For python
        deps = ["python-lsp-ruff", "pyrefly-bin"]
        # For nix
        deps += ["nixfmt"]
        return deps

    def after_update(self):
        # Installing the tools for python (mainly mdformat variants)
        python_env = os.path.join(user.home_path, ".cli-python")
        python_path = os.path.realpath(os.path.join(python_env, "bin/python"))
        cache_dir = os.path.join(user.home_path, ".local/share/uv/python")
        create_env_cmd = [
            "uv",
            "venv",
            "--cache-dir",
            cache_dir,
            "--no-managed-python",
            "--system-site-packages",
            python_env,
        ]
        if not os.path.isdir(python_env):
            decman.prg(create_env_cmd, user=user.username)
        elif not os.path.isfile(python_path):
            decman.prg(create_env_cmd, user=user.username)

        python_req = os.path.join(user.config_source_dir, "pkg/cli-python.txt")
        decman.prg(
            ["uv", "pip", "install", "--upgrade", "--no-cache", "-r", python_req],
            user=user.username,
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
            # For script auto completion in the command line
            "python-argcomplete",
            # To create progress bars and simple parallelism
            "python-tqdm",
            # Python interface for imagemagick
            "python-wand",
            # Required for handling the requests
            "python-requests",
            # Required for scriptize docstring parsing
            "python-numpydoc",
            # Commonly used for on-off data analysis scripts
            "python-numpy",
            "python-scipy",
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
        deps += ["tmux", "htop", "btop", "speedtest-cli", "tree"]
        # Configure file parsing
        deps += ["jq", "go-yq"]
        # Additional compression formats
        deps += ["zip", "unzip", "lzip"]
        # For direct interactions with the wayland clipboard
        deps += ["wl-clipboard"]
        # For zsh styling
        deps += ["starship"]
        return deps

    def aur_packages(self):
        # For looking up items in the AUR
        deps = ["paru-bin", "yay-bin"]
        # For python development
        deps += ["miniconda3"]
        return deps

    def files(self):
        return {
            os.path.join(user.home_path, ".condarc"): decman.File(
                content="\n".join(["auto_activate_base: false", "changeps1: false"])
            ),
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
