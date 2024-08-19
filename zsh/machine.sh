# Loading CMSSW configurations if possible
if [[ -d "/cvmfs/cms.cern.ch" ]] ; then
  source $HOME/.config/zsh/cmssw_tools.sh
fi

# Additional theme based on host name
if [[ ${HOST} == "ensc"* ]]; then # Personal machine
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7   # White
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232 # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=235 # DARK GRAY
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3   # Orange
elif [[ $HOST == "cmslpc"*".fnal.gov" ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=3 # ORANGE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=3 # ORANGE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232
elif [[ $HOST == "lxplus"*".cern.ch" ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=19 # DEEP BLUE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=7
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=19 # DEEP BLUE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=7
else
  ## HOSTNAME NOT LISTED!!
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=1          # RED
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232        # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=1   # RED
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232 # BLACK
fi
