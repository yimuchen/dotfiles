# If using zsh, I'm assuming that nix will be available

if [[ ${HOST} == "ensc"* ]]; then # Personal machine
  export EDITOR='nvim'
  source $HOME/.config/zsh/personal_tools.sh
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7   # White
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232 # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=235 # DARK GRAY
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3   # Orange
elif [[ $HOST == "cmslpc"*".fnal.gov" ]]; then
  source $HOME/.config/zsh/cmssw_tools.sh
  # Setting color
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=3 # ORANGE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=3 # ORANGE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232
elif [[ $HOST == "login-el"*".uscms.org" ]]; then
  source $HOME/.config/zsh/cmssw_tools.sh
elif [[ $HOST == "lxplus"*".cern.ch" ]]; then
  source $HOME/.config/zsh/cmssw_tools.sh
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=19 # DEEPBLUE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=7
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=19 # DEEPBLUE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=7
elif [[ $HOST == "hepcms"*".umd.edu" ]]; then
  source $HOME/.config/zsh/cmssw_tools.sh
else
  ## HOSTNAME NOT LISTED!!
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=1          # RED
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232        # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=1   # RED
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232 # BLACK
fi
