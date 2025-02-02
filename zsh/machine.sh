if [[ -z "${DOMAIN_NAME}" ]]; then
  export DOMAIN_NAME=$(domainname -d)
fi

# Additional theme based on host name
if [[ "$HOST" == "ensc"* ]]; then                # Personal machine
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7   # White
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232 # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=235 # DARK GRAY
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3   # Orange
elif [[ "$HOST" == "hepcms"* ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7   # White
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232 # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=235 # DARK GRAY
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=3   # Orange
  export CMSSW_APPTAINER_BINDPATH=/data,/data2
elif [[ "$HOST" == "cmslpc"* ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=3 # ORANGE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=3 # ORANGE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232
  export CMSSW_APPTAINER_BINDPATH=/uscms,/uscmst1b_scratch,/cvmfs,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/uscms_data
elif [[ "$HOST" == "lxplus"* && "$DOMAIN_NAME" == "cern.ch" ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=19 # DEEP BLUE
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=7
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=19 # DEEP BLUE
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=7
elif [[ "$DOMAIN_NAME" == "etp.kit.edu" ]]; then # KIT RELATED MACHINES
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=22  # DEEP GREEN
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=7
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=22 # DEEP GREEN
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=7
  export CMSSW_APPTAINER_BINDPATH=/ceph,/work,/home,/cvmfs/grid.cern.ch/etc/grid-security:/etc/grid-security,/etc/condor,/var/lib/condor
else
  ## HOSTNAME NOT LISTED!!
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=1          # RED
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232        # BLACK
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=1   # RED
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=232 # BLACK
fi

# Loading CMSSW configurations if possible (some configurations requires
# knowing the cluster configuration)
if [[ -d "/cvmfs/cms.cern.ch" ]]; then
  source $HOME/.config/zsh/cmssw_tools.sh
fi
