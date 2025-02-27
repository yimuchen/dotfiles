# Common aliases for commands:
alias -- dir_size='du --max-depth=1 --human-readable --all | sort --human-numeric-sort'
alias -- grp='grep --colour=always'
alias -- less='less --raw-control-chars'
alias -- ln='ln --symbolic --force'
alias -- ls='ls --group-directories-first -X --human-readable --color=auto'
alias -- nshell='nix develop -c $SHELL'
alias -- ping='ping -c 7 -i 0.200'
alias -- ping-test='ping www.google.com'
alias -- rm='rm -i'
alias -- root='root -l'
alias -- wget='wget --continue'

# Image browser compound command will be written as a function instead
alias -- icat='fzf_img_preview'

function img-browse() {
  find . -name '*.pdf' -o -name '*.png' -o -name '*.jpg' -o -name '*.svg' |
    fzf --preview 'fzf_img_preview {}' --preview-window=right,65%
}

# Additional utility for python develpment
# Required for conda autocomplete
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

function get_jupyter_url() {
  # Getting the url of the of the jupyter server session that is running in
  # this directory
  local json_file=$(ls -1t ${PWD}/.local/share/jupyter/runtime/jpserver-*.json | head -n 1)
  local token=$(jq -r '.token' ${json_file})
  local port=$(jq -r '.port' ${json_file})
  # Assuming that localhost is used to expose the runtime
  echo "http://localhost:${port}/?token=${token}"
}

function show_colors256() {
  # Solution obtained here:
  # https://stackoverflow.com/a/30578008
  local c i j

  printf "Standard 16 colors\n"
  for ((c = 0; c < 17; c++)); do
    printf "|%s%3d%s" "$(tput setaf "$c")" "$c" "$(tput sgr0)"
  done
  printf "|\n\n"

  printf "Colors 16 to 231 for 256 colors\n"
  for ((c = 16, i = j = 0; c < 232; c++, i++)); do
    printf "|"
    ((i > 5 && (i = 0, ++j))) && printf " |"
    ((j > 5 && (j = 0, 1))) && printf "\b \n|"
    printf "%s%3d%s" "$(tput setaf "$c")" "$c" "$(tput sgr0)"
  done
  printf "|\n\n"

  printf "Greyscale 232 to 255 for 256 colors\n"
  for (( ; c < 256; c++)); do
    printf "|%s%3d%s" "$(tput setaf "$c")" "$c" "$(tput sgr0)"
  done
  printf "|\n"
}

# Helper functions for getting tmux spin up
alias -- ctmux="$HOME/.config/tmux-plugins-custom/cluster-session/scripts/ctmux attach-session"

####################################
## Functions for modifying command line behavior

function _add_buffer_prefix() {
  # Function for checking the current working directory, and seeing if command
  # should be augmented by a command prefix

  ## Check if in CMSSW environment
  if command -v _cmsexec 2>&1 >/dev/null; then
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

function modify-accept-line() {
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
    elif command -v _apptainer_conda.sh 2>&1 >/dev/null; then
      BUFFER="_apptainer_conda.sh $BUFFER"
    fi
  fi

  # Do not modify this line
  zle .accept-line
}

zle -N accept-line modify-accept-line
