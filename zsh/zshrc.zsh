# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation. And some additional variable to handle
# oh-my-zsh settings. Do not attempt to change the order
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-my-zsh auto update settings
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Which plugins would you like to load?
plugins=(git vi-mode conda-zsh-completion)
autoload -U compinit && compinit
source $ZSH/oh-my-zsh.sh

# User configurations - main items will be split into other files
export EDITOR='nvim'

# Additional utility functions that will be provided in separate files
source $HOME/.zsh/common_utils.sh
source $HOME/.zsh/conda_path.sh
# Additional theme settings is stored in p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ ${HOST} == "ensc"* ]]; then # Personal machine
  export EDITOR='nvim'
  alias  nv='nvim'
  source $HOME/.zsh/personal_tools.sh
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7   # White
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232 # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=235 # DARK GRAY
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3   # Orange
elif [[ $HOST == "cmslpc"*".fnal.gov" ]] ; then
  source $HOME/.zsh/nix.sh
  source $HOME/.zsh/cmssw_tools.sh
  # Setting color
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=3  # ORANGE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=3  # ORANGE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232
elif [[ $HOST == "login-el"*".uscms.org" ]]; then
  source $HOME/.zsh/cmssw_tools.sh
elif [[ $HOST == "lxplus"*".cern.ch" ]] ; then
  source $HOME/.zsh/cmssw_tools.sh
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=19  # DEEPBLUE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=7
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=19  # DEEPBLUE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=7
elif [[ $HOST == "hepcms"*".umd.edu" ]] ; then
  source $HOME/.zsh/cmssw_tools.sh
else
  ## HOSTNAME NOT LISTED!!
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=1   # RED
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232 # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=1   # RED
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=232 # BLACK
fi



# As conda initialize is handled separately for each machine, we look at the
# path defined in the zsh/conda_path.sh methods

