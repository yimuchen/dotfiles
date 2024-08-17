####
# Additional helper functions for interacting with CMSSW compatible system

# To not attempt to pass SHH agent (this is handled elsewhere)
unset SSH_ASKPASS

# Explicitly defining certificate files
export X509_USER_PROXY=${HOME}/x509up_u${UID}
alias init-voms='voms-proxy-init -voms cms --valid 192:00 --out ${X509_USER_PROXY}'

# Modifications to common command line tools
alias htop='htop --user ${USER}'
alias wget='wget --no-check-certificate'

# CMSSW tool chain helper function
alias usecrab='source /cvmfs/cms.cern.ch/crab3/crab.sh'

# Loading the cmssw settings if not already loaded
if [[ -z "${SCRAM_ARCH}" ]]; then
   source /cvmfs/cms.cern.ch/cmsset_default.sh
fi

function smake() {
   # Function for running scram b on half the cores available
   if [ -z "$CMSSW_BASE" ]; then
      echo "\$CMSSW_BASE is not defined, make sure you are in a CMSSW environment"
      return 1
   fi

   local num_core=$(nproc)
   local run_core=$((num_core / 2))
   echo "Running on $run_core(out of $num_core) threads.."
   cd ${CMSSW_BASE}/src
   scram b -j $run_core
   cd -
}

function condor_q_brief() {
   condor_q -total | grep $USER && condor_q -total | grep 'all user'
}

function dev_tmux() {
   if [ "$#" -ne 1 ]; then
      local session_name=$(basename $PWD)
   else
      local session_name=$1
   fi
   tmux has-session -t $session_name 2>/dev/null
   if [ $? != 0 ]; then
      # If a tmux session doesn't already exist, set up a default session!
      tmux new-session -d -s $session_name

      # Main windows for editors, browsing the file system and monitoring a run condition
      tmux rename-window -t ${session_name}:0 "Editor"
      tmux respawn-pane -t ${session_name}:0.0 -k "zsh -c 'nvim .'"

      # Executing the command
      tmux new-window -n "Run/Monitor"
      tmux select-window -t ${session_name}:1 # Monitor tab
      tmux split-window -t ${session_name}:1
      tmux split-window -t ${session_name}:1
      tmux resize-pane -t ${session_name}:1.0 -y "25%"
      tmux resize-pane -t ${session_name}:1.1 -y "25%"
      tmux respawn-pane -t ${session_name}:1.0 -k "htop --user $USER"
      tmux respawn-pane -t ${session_name}:1.1 -k "watch -n 3 \"condor_q -total | grep $USER && condor_q -total | grep 'all user'\""
      tmux respawn-pane -t ${session_name}:1.2 -k "zsh -l" # For running commands

      # Switching the to the editor window by default
      tmux select-window -t ${session_name}:0
   fi

   tmux attach-session -t $session_name
}
