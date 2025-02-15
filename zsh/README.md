# ZSH configurations

There are 2 core files that are common to all configurations:

- [`$HOME/.zshenv`](./zshenv): this is evoked for all calls to `zsh` regardless
  of if it is a login shell or a call by another application (`neovim` or
  `tmux` or anything else). Here we will attempt to set up all possible
  variations of the `$PATH` variables and other environment variables, as this
  ensures that all programs can see the same environment and binaries that are
  used by the various programs. Certain environment variables are also set here
  to help detect whether the machine in question is a remote system (one where
  the user likely only has limited access), or whether this is a "local"
  machine where the user will typically have more control.

- [`$HOME/.zshrc`](./zshrc): this is only used for `zsh` login shells that the
  user will interact with. So this mainly includes the functions that will help
  with using the session interactively such as aliases, helper function, short
  hands functions, output eye candy and such. This file will also load the
  following methods.

  - [`common_utils.sh`](./common_utils.sh): Where common utility functions are
    placed.
  - [`local.sh`](./local.sh): Where the utilities that are useful for system
    management is placed.
  - [`remote.sh`](./remote.sh): Where the utility functions that only make
    sense for remote sessions are placed.
  - [`cmssw_tools.sh`](./cmssw_tools.sh): A special subset of utilities for
    interacting with CMSSW related tools (only exposed for remote sessions as
    well).
  - [`p10k.zsh`](./p10k.zsh): A special file that was generated for the prompt
    designer
