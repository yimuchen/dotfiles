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
export EDITOR='vim'
HIST_STAMPS="yyyyy-mm-dd"

# Additional utility functions that will be provided in separate files
source $HOME/.zsh/common_utils.sh
source $HOME/.zsh/conda_path.sh

if [[ ${HOST} == "ensc"* ]]; then # Personal machine
  export EDITOR='nvim'
  alias  nv='nvim'
  source $HOME/.zsh/personal_tools.sh
elif [[ $HOST == "cmslpc"*".fnal.gov" ]] ; then
  source $HOME/.zsh/cmssw_tools.sh
elif [[ $HOST == "login-el"*".uscms.org" ]]; then
  source $HOME/.zsh/cmssw_tools.sh
elif [[ $HOST == "lxplus"*".cern.ch" ]] ; then
  source $HOME/.zsh/cmssw_tools.sh
elif [[ $HOST == "hepcms"*".umd.edu" ]] ; then
  source $HOME/.zsh/cmssw_tools.sh
fi

# Additional theme settings is stored in p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# As conda initialize is handled separately for each machine, we look at the
# path defined in the zsh/conda_path.sh methods

