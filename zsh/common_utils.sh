# Common aliases for commands:
alias -- dir_size='du --max-depth=1 --human-readable --all | sort --human-numeric-sort'
alias -- grp='grep --colour=always'
alias -- less='less --raw-control-chars'
alias -- ln='ln --symbolic --force'
alias -- ls='ls --group-directories-first -X --human-readable --color=auto'
alias -- nshell='nix develop -c $SHELL'
alias -- nshell-lua='nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#lua -c $SHELL'
alias -- nshell-py3p10='nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#python-3p10'
alias -- nshell-py3p11='nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#python-3p11'
alias -- nshell-py3p12='nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#python-3p12'
alias -- nshell-tex='nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#tex -c $SHELL'
alias -- ping='ping -c 7 -i 0.200'
alias -- ping-test='ping www.google.com'
alias -- rm='rm -i'
alias -- root='root -l'
alias -- wget='wget --continue'

# Required for ensuring that a zsh binary is accessible to the tmux session
ln -sf $(which zsh) $HOME/.local/zsh

# Additional utility function
function get_jupyter_url() {
   # Getting the url of the of the jupyter server session that is running in
   # this directory
   local json_file=$(ls -1t ${PWD}/.local/share/jupyter/runtime/jpserver-*.json | head -n 1)
   local token=$(jq -r '.token' ${json_file})
   local port=$(jq -r '.port' ${json_file})
   # Assuming that localhost is used to expose the runtime
   echo "http://localhost:${port}/?token=${token}"
}

function show_term_color() {
  for i in {0..255}; do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'};
  done
}


function _add_buffer_prefix() {
  # Function for checking the current working directory, and seeing if command
  # should be augmented by a command prefix

  ## Check if in CMSSW environment
  if command -v _cmsexec 2>&1 > /dev/null ; then
    if [[ $(_cmssw_src_path) != "" ]]; then
      echo "_cmsexec "
      return
    fi
  fi

  ## Check if there is a defined apptainer command
  if [[ -f "$PWD/.apptainer.sh" ]]; then
    echo "$PWD/.apptainer.sh "
    return
  fi
}

function modify-accept-line () {
  # Notice that this function can never have output, the only thing we can do
  # is modify the BUFFER variable. Any modifications done here will
  # automatically be including in all the history items so that we will never
  # forget the command that you ran.

  default_prefix=$(_add_buffer_prefix)
  if [[ $BUFFER == ./* ]]; then # Attempting to run a custom script/binary
    BUFFER="${default_prefix}${BUFFER}"
  elif [[ $BUFFER == cmsRun* ]] || [[ $BUFFER == scram* ]]; then # cmsRun binaries
    BUFFER="${default_prefix}$BUFFER"
  elif [[ $BUFFER == python* ]] || [[ $BUFFER == pip* ]]; then
    # For python executions test if try the default solution first, otherwise
    # load the default condor image for default python development
    if [[ ${default_prefix} != "" ]]; then
      BUFFER="${default_prefix}$BUFFER"
    elif command -v _apptainer_conda.sh 2>&1 > /dev/null ; then
      BUFFER="_apptainer_conda.sh $BUFFER"
    fi
  fi

  # Do not modify this line
  zle .accept-line
}

zle -N accept-line modify-accept-line
