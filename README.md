# Reloading command line tools

This is the set of tools that I use for day-to-day activity. Each major
component will include each of it's copy-and-paste install instructions,
assuming that you are working from the base directory of this repository. To
allow changes to be reflected immediately after any edits, all custom files
will be soft-linked to the required repositories.

## Installation

The dependencies for running the various items here can be handled either by:

- [`decman`][decman]: The declarative wrapper for [Archlinux]'s [pacman]. The
  modules for using that can be found in the [`decman`](./decman/) directory.
- [`home-manager`][homemanager]: The declarative system used by
  [Nix/NixOS][nix], simply copy this directory to the standard
  `~/.config/home-manager/` directory, and run `home-manager switch` to get the
  packages defined here repository.
- [`gentoo-protage`][portage] (currently CLI-only): the list of packages that
  are to be installed can be found in the
  [`portage-cli-tools.txt`](./portage-cli-tools.txt) file. Pipe the contents to
  the `emerge` command to save this.

After the main package installs, you will still need to add the various
configuration files as a symbolic links into you user directory. This
repository provides the `symlinkmgr` tool in the [`./bin/common/`](./bin)
directory, and you can run this like:

```bash
./bin/common/symlinkmgr ./config/links-cli.txt
```

This links that are managed by this tool will be kept in a log file so that
links can be cleanly removed when the system is updated.

## What should be handled by package managers?

The package managers should be used for getting the libraries required to use
the user tools and ideally nothing more. This is an attempt to help ensure that
this same repository can be used regardless of what system is being used, and
not tied to any single package management system. Configuration should largely
be handled by the `symlinkmgr` mentioned above. One exception to this rule is
the use of `decman` to hard-wire GUI configuration into the user home
directory. These are configurations that are not expected to be changed often.

## The general layout

- [`config`](./config): this directory should mirror the structure that is used
  in `$HOME/.config` for files that you want to have version managed. Most
  application configurations are expected to sit here and be linked to the home
  folder. There are 3 exceptional applications that we want the directories to
  be elevated to the primary directory:

  - [`nvim`](./nvim): My preferred [text editor][neovim], with the most
    involved configuration.
  - [`zsh`](./zsh): My preferred [shell][zsh], with the most machine-dependent
    configurations.
  - [`tmux`](./tmux): My preferred [terminal multiplexer][tmux], with the
    (currently) my most experimental developments.

- [`share`](./share/): this directory should mirror the structure that is used
  in `$HOME/.local/share` for files that you want to have version managed.
  These typically contain small, one-off configurations for some
  cross-application configurations.

- [`bin`](./bin): Custom helper scripts for terminal applications. The scripts
  here should either be python or bash, with the more exotic dependencies
  listed by the package manager session. There are currently 3 categories, the
  exposure of these paths are handled by the `zsh` configurations.

  - [`common`](./bin/common): Useful terminal application that can be used
    anywhere.
  - [`local`](./bin/local): Only useful if you are the system admin of primary
    user for of the machine.
  - [`remote`](./bin/remote): Only useful if when working on a remote machine
    (over and `ssh`) connection for example.

- [`misc`](./misc/): Configuration for standard but not preferred tools: `bash`
  and `vim`. These will not be handled directly, but should serve as a
  reference for when setting on an environment where the fancier tools are not
  available.

- [`pkg`](./pkg): This is where the package management files should be placed.

## Latex settings

Custom latex aliasing, symbols and styling files. This is mainly for standalone
documents generate without minimum document format restrictions and _not_
publication ready. For any serious publications, it would be better to directly
create a separate copy to ensure the object styles are properly frozen.

The packages here expected most of the common [`texlive`][texlive] packages for
math writing are installed in the system (which should be the case after
installing the more common `texlive-*` packages from the official Arch
repository) Some external dependencies might be needed for the font
configuration to function. For additional details, see the
[`texmf/tex/latex/README`](texmf/tex/latex).

[archlinux]: https://archlinux.org/
[decman]: https://github.com/kiviktnm/decman
[homemanager]: https://nix-community.github.io/home-manager/
[neovim]: https://neovim.io/
[nix]: https://nixos.org/
[pacman]: https://wiki.archlinux.org/title/Pacman
[portage]: https://wiki.gentoo.org/wiki/Portage
[texlive]: https://www.tug.org/texlive/
[tmux]: https://github.com/tmux/tmux/wiki
[zsh]: https://www.zsh.org/
