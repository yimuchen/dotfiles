# Reloading command line tools

This is the set of tools that I use for day-to-day activity. Each major
component will include each of it's copy-and-paste install instructions,
assuming that you are working from the base directory of this repository. To
allow changes to be reflected immediately after any edits, all custom files
will be soft-linked to the required repositories.

The repository is slowly transitioning into using [nix]
[home-manager][homemanager] for bootstrapping all the configurations to the
home directory. When it is complete, the installation process should be
directly:

```bash
git clone https://github.com/yimuchen/dotfiles
rm ~/.config/home-manager -rf                     # Removing existing home-manager configuration
ln <path >/ <to >/dofiles ~/.config/home-manager/ # Linking this repository to home manager
home-manager switch                               # Is required to rerun if you make edits to the dotfiles directory
```

While the bootstrapping is being finalized, additional instructions will be
provided to ensure that configurations can still be used (especially for system
where nix is still not available)

## What should be handled by nix?

Using nix as the package manager does not quite solve the problem of all
configuration managements methods that can exist for the packages that we can
use. The rule of thumb would be:

- If the configurations contain programmable logic (like with `neovim` and
  `zsh`), the configuration should always attempt to use the packages native
  configuration method rather than using nix. Nix in this case will be used to
  set up links to the configuration.
- If the configurations dependencies packages that uses is not native to the
  configuration language (like language specific tools for `neovim`, or
  wrappers to make certain CLI tools easier to use), these should be handled as
  nix dependencies. This is mainly to help ensure that consistent development
  session can be configured with nix flake files.
- All setting up of symbolic links for various configurations that are not
  easily handled by existing home manager configuration options. The
  miscellaneous configuration files in this case would be listed under the
  `config` and the `share` directory. And the structure within this directory
  should mirror what is expected in the `$HOME/.config` and
  `$HOME/.local/share` directory respectively.

## Shell (`zsh`)

The additional plugin system used will be [`antidote`][antidote], while the
downloading of packages defined by antidote will be handled by nix. This
ensures that the configured system will have a fully functioning `zsh`, and you
will not be prompted with a message when first logging into the shell.

Aliases for standard `coreutils` tools, and some non-trivial combination of
such tools will be defined in the nix configurations. Programmable
configurations should be defined in the separate `zsh/*.sh` files, such that
they can be quickly updated when running into a bug without having to rebuild
the system.

## Shell helper scripts

Additional helper scripts used for performing common routines in a CLI session
should be store in subdirectories in the `zsh` folder. The individual nix
configurations used for grouping terminal functionality would be used to expose
these directories and the global `$PATH` variable. The scripts here should use
vanilla `sh` where ever possible, as avoid using `nix` specific paths to
complete the routine (i.e: the script should expected executable files to be
exposed instead of pointing to a specific nix executable instance), as this
ensure the same scripts can be ported to other systems that is not running Nix.

## Python helper scripts

For more complicated routines, python scripts with `subprocess` is a little
easier to handle than bash scripts. Such tools will be provided in the
[`pyscripts`](pyscripts) directory. The nontrivial python dependencies are
listed in the [`pyscripts/requirements.txt`](pyscripts) file, though you should
instead use the system package manager to install these python dependencies.
Once you have installed the python dependencies, the scripts can be enabled run
the following commands:

```bash
# Linking scripts to the common position
ln -sf $PWD/pyscripts $HOME/.pyscripts

# If this line is not already somewhere in your shell configurations
export PATH=$PATH:$HOME/.pyscripts

# Ensuring that python auto complete is main available (scripts can still be used is not done)
activate-global-python-argcomplete --user
```

## Neovim configuration

The organization of neovim configurations follows the example found in the
tutorial made by the [ThePrimeagen][primetut]. As the configuration of neovim
also runs into external dependency management, this should always be coupled
with the other session configurations (see the `README.md` file in the
[`nvim`](nvim) directory for more information).

On the initial start up the lazy package manager should automatically start
pulling the required packages. For how the neovim configuration is done, see
the documentation in [`nvim/README.md`](nvim) file.

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

## Plasma configurations

Currently, plasma configurations are not easily performed by nix, we will be
keeping track of the required `rc` files in the plasma directory. The file
structure in the `plasma` should follow how the files are structured in the
`~/.config` directory. The construction of the symlink as well as why certain
items are required to kept will be handled by `nix` home-manager.

## Miscellaneous

Miscellaneous configuration that we will be using for the commonly used
"vanilla" unix system, such as vim instead of neovim, bash instead of zsh and
so on. These files will **not** be managed by nix/home-manager, and should be
directly modified/copied to the target file.

[antidote]: https://github.com/mattmc3/antidote
[homemanager]: https://nix-community.github.io/home-manager/
[nix]: https://nixos.org/
[primetut]: https://www.youtube.com/watch?v=w7i4amO_zaE
[texlive]: https://www.tug.org/texlive/
