# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation. And some additional variable to handle
# oh-my-zsh settings. Do not attempt to change the order
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.omz-custom/"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-my-zsh auto update settings
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Additional packages that we should make sure to install
if [ ! -d ${ZSH} ] ; then
  mkdir -p ${ZSH}
  git clone https://github.com/ohmyzsh/ohmyzsh.git ${ZSH}
fi
if [ ! -d ${ZSH_CUSTOM}/themes/powerlevel10k ] ; then
  mkdir -p ${ZSH_CUSTOM}/themes
  git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
fi
if [ ! -d ${ZSH_CUSTOM}/plugins/conda-zsh-completion ] ; then
  mkdir -p ${ZSH_CUSTOM}/plugins
  git clone https://github.com/conda-incubator/conda-zsh-completion.git ${ZSH_CUSTOM}/plugins/conda-zsh-completion
fi

# Which plugins would you like to load?
plugins=(git vi-mode conda-zsh-completion)
autoload -U compinit && compinit -u

# Loading in the plugins
source $ZSH/oh-my-zsh.sh

# Additional utility functions that will be provided in separate files
source $HOME/.zsh/common_utils.sh

# Additional theme settings is stored in p10k.zsh
[[ ! -f ~/.zsh/p10k.zsh ]] || source ~/.zsh/p10k.zsh

if [[ ${HOST} == "ensc"* ]]; then # Personal machine
  export EDITOR='nvim'
  source $HOME/.zsh/nix.sh
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
  source $HOME/.zsh/nix.sh
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
