####
# Additional helper functions for interacting with CMSSW compatible system

# To not attempt to pass SHH agent (this is handled elsewhere)
unset SSH_ASKPASS

# Explicitly defining certificate files
export X509_USER_PROXY=${HOME}/x509up_u${UID}
alias init-voms='voms-proxy-init -voms cms --valid 192:00 --out ${X509_USER_PROXY}'

# CMSSW tool chain helper function
alias usecrab='source /cvmfs/cms.cern.ch/crab3/crab.sh'

# Loading the cmssw settings if not already loaded
if [[ -z "${SCRAM_ARCH}" ]]; then
  source /cvmfs/cms.cern.ch/cmsset_default.sh
fi

# Additional bind paths for cmssw-elX. Notice that the paths will need to be
# different for different cluster setups.
_CMSSW_APPTAINER_BINDARGS="--bind ${CMSSW_APPTAINER_BINDPATH//,/ --bind }"
alias cmssw-el7-int="cmssw-el7 -p ${_CMSSW_APPTAINER_BINDARGS} -- /bin/bash -l"
alias cmssw-el8-int="cmssw-el8 -p ${_CMSSW_APPTAINER_BINDARGS} -- /bin/bash -l"
alias cmssw-el9-int="cmssw-el9 -p ${_CMSSW_APPTAINER_BINDARGS} -- /bin/bash -l"

# Some aliases for running CMSSW related environments
export _CMSSW_SCRAM_ARCH_CACHE=$HOME/.cache/cmssw_scram_arch.txt
function _build_cmssw_scram_arch() {
  echo "" >$_CMSSW_SCRAM_ARCH_CACHE # Wipe the existing file
  # Adding items into cache file, ensuring that newer architectures are
  # automatically loaded into the file later
  ls -1 -d /cvmfs/cms.cern.ch/slc7_amd64_gcc*/cms/cmssw/CMSSW* >>$_CMSSW_SCRAM_ARCH_CACHE
  ls -1 -d /cvmfs/cms.cern.ch/slc7_amd64_gcc*/cms/cmssw-patch/CMSSW* >>$_CMSSW_SCRAM_ARCH_CACHE
  ls -1 -d /cvmfs/cms.cern.ch/el8_amd64_gcc*/cms/cmssw/CMSSW* >>$_CMSSW_SCRAM_ARCH_CACHE
  ls -1 -d /cvmfs/cms.cern.ch/el8_amd64_gcc*/cms/cmssw-patch/CMSSW* >>$_CMSSW_SCRAM_ARCH_CACHE
  ls -1 -d /cvmfs/cms.cern.ch/el9_amd64_gcc*/cms/cmssw/CMSSW* >>$_CMSSW_SCRAM_ARCH_CACHE
  ls -1 -d /cvmfs/cms.cern.ch/el9_amd64_gcc*/cms/cmssw-patch/CMSSW* >>$_CMSSW_SCRAM_ARCH_CACHE
}

# Exposing CMSSW container detection tools. This needs to be isolated to
# separate scripts in the $PATH environment variable to allow these fundamental
# tools be also be used in other tools (neovim)

# Simple alias functions to directly call CMSSW methods without having to load in cmsenv
function cmssw-clean() {
  _cmsexec scram b clean
}

function cmssw-make() {
  # Standard make methods
  #
  # Always move to base path to compile everything
  cmssw_src=$(_cmssw_src_path)
  cd ${cmssw_src}

  # Compile with half the available cores
  _cmsexec scram b -j $(($(nproc) / 2))

  # Generate the compile commands and link it to the src base path
  _cmsexec scram b llvm-ccdb
  ln -sf ${cmssw_src}/../compile_commands.json ./

  # Moving back to whatever working directory was used
  cd -
}


function condor_q_brief() {
  condor_q -total | grep $USER && condor_q -total | grep 'all user'
}

function create_bashrc() {
  # Function for creating the default ~/.bashrc file for the cluster side. By
  # default this will only dump the contents to STDOUT to avoid automatically
  # breaking the default login session.
  cat <<EOF
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
alias nix-rebuild="nix-portable nix shell 'nixpkgs#nix' 'nixpkgs#zsh' 'nixpkgs#tmux' --command zsh -l"
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

