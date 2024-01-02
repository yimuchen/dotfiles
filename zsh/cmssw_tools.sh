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
alias usecms='source /cvmfs/cms.cern.ch/cmsset_default.sh'

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
