# packages management

The primary source for package to be installed for the user would be what is listed in the various `decman` modules in
the [`./decman`](./decman) directory. The packages listed in the [`./nix`](./nix) directory should be a similar list,
but is not guaranteed to be kept up to date. A subset of the libraries listed in the `decman/cli.py` modules is also
listed in the `./portage-cli-tools.txt` as these will be used to install the command line package on remote servers.

## Language specific tools

There are niche cases where the tool are only fully accessible via some language specific install environments. Common
use cases include new tools written in `python`, `rust` and `go` that have not yet been propagated to the central
repositories of the various Linux distribution. For these types of tools, we will expose a common command path in the
user home directory, and the installed packages will be listed as a plain-text list of files. Ideally these lists should
be as short as possible, and one should always try and keep the package management of tools to be handled by the system
package manager where-ever possible.

### rust-specific tools

After attempting to install something via `cargo`, it will by default place the executable file under the directory
`$HOME/.cargo/bin`, this is where we will expose the path.

### Python-specific tools

I am using the `python-uv` virtual environment to install a user-level instance of a python virtual environment at
`$HOME/.cli-python`. Notice that tools/scripts install in this directory should automatically be generated with the
`shebang` that points to the python in this virtual environment. It should be the case that we can just expose this path
to the virtual environment's `bin` directory instead of having a virtual environment be silently active all the time.
