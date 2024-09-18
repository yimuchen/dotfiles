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

function create_bashrc() {
  # Function for creating the default ~/.bashrc file for the cluster side. By
  # default this will only dump the contents to STDOUT to avoid automatically
  # breaking the default login session.
  cat << EOF
# .bashrc (Auto generated)

# Source global definitions handled by the system administrators
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Setting up methods for ensuring that nixi-portable can be used
export NP_RUNTIME=bwrap
export NP_LOCATION=${LARGE_STORAGE_DIR}/nix-setup/
export PATH=\$NP_LOCATION:\$PATH
alias nix-zsh-shell="nix-portable nix shell --offline 'nixpkgs#nix' 'nixpkgs#zsh' 'nixpkgs#tmux' --command zsh -l"
EOF
}

function manage_cache() {
  # Function to help with managing the larger cache directories
  echo "Moving caches from store directory to a larger permanent directory"
  local cache_dir="${LARGE_STORAGE_DIR}/cache_large"
  for dir_name in "mamba" "conda" "cache" "apptainer"; do
    mkdir -p ${cache_dir}/${dir_name}
    ln -sf ${cache_dir}/${dir_name} $HOME/.${dir_name}
  done
}

