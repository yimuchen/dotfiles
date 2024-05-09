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
rm ~/.config/home-manager -rf # Removing existing home-manager configuration
ln <path>/<to>/dofiles ~/.config/home-manager/ # Linking this repository to home manager
home-manager switch # Is required to rerun if you make edits to the dotfiles directory
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
  configuration language (like language specific tools for `neovim`), these
  should be handled as nix dependencies. This is mainly to help ensure that
  consistent development session can be configured with nix flake files.

## Shell (ZSH)

The manager system [`oh-my-zsh`][oh-my-zsh] will be used to handle the primary
tools. Additional configuration that helps with day-to-day tasks on specific
machines, as well as additional settings for the plugins will be added to the
contents of the [`zsh`](zsh) folder. A simple parsing is done on the main
`zshrc` script to determine the machine type and load in the required methods.

Assuming that you already have `zsh` installed, the settings can be loaded in
with the following commands:

```bash
# First time setup for oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# First time setup for powerlevel10k zsh theme and conda zsh completion
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/esc/conda-zsh-completion ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/conda-zsh-completion

# Linking the various files
ln -sf $PWD/zsh             $HOME/.zsh
ln -sf $HOME/.zsh/zshrc.zsh $HOME/.zshrc
ln -sf $HOME/.zsh/p10k.zsh  $HOME/.p10k.zsh
```

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

To install the required plugins using [`lazy.nvim`][lazy.nvim] after installing
the case neovim, first link the configuration files to the common configuration
location:

```bash
## In case you want to make sure you start with a clean state. Be care that you
## backup your own configuration!!

# rm $HOME/.config/nvim
# rm $HOME/.local/share/nvim

ln -sf $PWD/nvim $HOME/.config/nvim
```

On the initial start up the lazy package manager should automatically start
pulling the required packages. For how the neovim configuration is done, see
the documentation in [`nvim/README.md`](nvim) file.

## Latex settings

Custom latex aliasing, symbols and styling files. This is mainly for standalone
documents generate without minimum document format restrictions and _not_
publication ready. For any serious publications, it would be better to directly
create a separate copy to ensure the object styles are properly frozen.

The usage of this should simply be the linking the `texmf` directory to your
home directory:

```bash
ln -sf $PWD/texmf $HOME/texmf
```

The packages here expected most of the common [`texlive`][texlive] packages for
math writing are installed in the system (which should be the case after
installing the more common `texlive-*` packages from the official Arch
repository) Some external dependencies might be needed for the font
configuration to function. For additional details, see the
[`texmf/tex/latex/README`](texmf/tex/latex).

## Conda

For setting up python virtual environment for python code development, we
expect the user the use [`conda`][conda] to create the virtual environment,
then use `pip install -e ./<package>` to include the developing package in edit
mode. For all `conda` environments, the default python linter (flake8) and
formatters (`black` and `isort`) to be always available to the virtual environment.
(TODO: check how flake8 interacts with the LSP settings). To use this setting
simply link `condarc` to the home folder.

```bash
ln -sf $PWD/condarc $HOME/.condarc
```

[conda]: https://docs.conda.io/en/latest/
[homemanager]: https://nix-community.github.io/home-manager/
[lazy.nvim]: https://github.com/folke/lazy.nvim
[mason]: https://github.com/williamboman/mason.nvim
[nix]: https://nixos.org/
[oh-my-zsh]: https://github.com/ohmyzsh/ohmyzsh/tree/master
[primetut]: https://www.youtube.com/watch?v=w7i4amO_zaE
[texlive]: https://www.tug.org/texlive/
