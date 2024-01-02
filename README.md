# Reloading command line tools

This is the set of tools that I use for data to day activity. Each component
will include each of it's copy-and-paste install instructions, assuming that
you are working from the base directory of this repository. To allow changes
to be reflected directly, all custom files will be soft-linked to the required
repositories.

## Shell (ZSH)

The manager system [oh-my-zsh][oh-my-zsh] will be used to handle the primary
tools. Additional configuration that helps with day-to-day tasks on specific
machines will be added to the contents of the [`zsh`](zsh) folder. A simple
parsing is done on the main zshrc script to determine the machine type and load
in the required methods. Assuming that you already have zsh installed:

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

[oh-my-zsh]: https://github.com/ohmyzsh/ohmyzsh/tree/master

## Python helper scripts

Certain tools are easier to complete with python. Such tools will be provided
in the [`pyscripts`](pyscripts) directory. These scripts are supposed to be
standalone, however. There are nontrivial python dependencies. These
dependencies should be installed at the system level, while the dependencies
will be listed in the [`pyscripts/requirements.txt`](pyscripts) file, you
should instead use the system package manager to install these python
dependencies. Once you have installed the python dependencies you can run the
following commands:

```bash
# Linking scripts to the common position
ln -sf $PWD/pyscripts $HOME/.pyscripts
# Ensuring that python auto complete is main available (scripts can still be used is not done)
activate-global-python-argcomplete --user
```

## Neovim configuration

This also handles the configuration files of the neovim editor. The
organization of these files follows the example found in [Theprimeagen
tutorial][primetut]. Right now, the configurations are still small enough and
makes sense to be tied with the all other system tools. This might not be the
case in the future. For the installation of all defined plugins, you should be
able to simple run the command:

```bash
# Installing the nvim plugin manage packer
git clone --depth 1 https://github.com/wbthomason/packer.nvim  ~/.local/share/nvim/site/pack/packer/start/packer.nvim
# Loading in our configuration files
ln -sf $PWD/nvim $HOME/.config/nvim
```

Then, in a neovim session run the command `PackerSync`, then all packages
should be automatically handled. Then restart neovim environment and run
`MasonToolsUpdate` to ensure all external dependencies handled by mason are
installed on your system. As certain tools warrant system-wide configurations,
not everything will be handled by the mason environment installer. For a list
of required additional dependencies, see additional information listed in the
[`nvim/README.md`](nvim) file.

By default, the formatter plugin will attempt to use the formatter
configuration file closest to the working directory of neovim instance (so
using CWD to determine the formatting style). For a global formatting style to
be used where a project might not have a set style, we define the default
formatting styles in the [`nvim/format_cfg`](nvim/format_cfg) to be linked to
the user home directory.

## Latex settings

Custom latex aliasing and symbols and styling files. This is mainly for
standalone documents generate without any document restrictions. In the case of
publications, it would be better to directly create a separate copy to ensure
the object styles are properly frozen.

The usage of this should simply be the linking the `texmf` directory to your home directory:

```bash
ln -sf $PWD/texmf $HOME/texmf
```

The packages here expected most of the common texlive packages for math writing
are installed in the system (which should be the case after installing the more
common `texlive-*` packages from the official Arch repository) Some external
dependencies might be needed for the font configuration to function. For
additional details, see the [`texmf/tex/latex/README`](texmf/tex/latex).

## Conda 

For setting up python virtual environment for python code development, we
expect the user the use conda to create the virtual environment, then use `pip
install -e ./<package>` to include the developing package in edit mode. For the
conda settings, we set the default python linter (flake8) and formatters (black
and isort) to always be available in the virtual environment. (TODO: check how
flake8 interacts with the LSP settings). To use this setting simply link
`condarc` to the home folder.

```bash
ln -sf $PWD/condarc $HOME/.condarc
```
