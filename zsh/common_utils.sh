# Common aliases for commands:
alias -- dir_size='du --max-depth=1 --human-readable --all | sort --human-numeric-sort'
alias -- grp='grep --colour=always'
alias -- ln='ln --symbolic --force'
alias -- nshell='nix develop -c $SHELL'
alias -- ping='ping -c 7 -i 0.200'
alias -- ping-test='ping www.google.com'
alias -- rm='rm -i'
alias -- root='root -l'
alias -- wget='wget --continue'
# Display commands should be ignored in command history to avoid clutter
alias -- less=' less --raw-control-chars'
alias -- ls=' ls --group-directories-first -X --human-readable --color=auto'
alias -- icat=' icat'
alias -- cat=' cat'

# Counting number of files
function dir_count() {
  for p in $(find . -maxdepth 1 -type d); do echo $(find $p -type f | wc -l) $p; done | sort -n
}

# Helper functions for fzf!
# Enable FZF integration
export FZF_CTRL_T_OPTS="--walker file,dir,follow --walker-skip .git,node_modules,target "
export FZF_ALT_C_OPTS="--walker dir,follow --walker-skip .git,node_modules,target --preview 'tree -C {}'"
eval "$(fzf --zsh)"
# Addiing additional keybinds to fzf widges
bindkey -M emacs '\ef' fzf-file-widget
bindkey -M vicmd '\ef' fzf-file-widget
bindkey -M viins '\ef' fzf-file-widget
bindkey -M emacs '\eh' fzf-history-widget
bindkey -M vicmd '\eh' fzf-history-widget
bindkey -M viins '\eh' fzf-history-widget

# Image browser compound command will be written as a function instead
alias -- icat='fzf_img_preview'

function img-browse() {
  find . -name '*.pdf' -o -name '*.png' -o -name '*.jpg' -o -name '*.svg' |
    fzf --preview 'fzf_img_preview {}' --preview-window=right,65%
}

function gp_find_cmd() {
  find . \( -path '*/.local/*' \
    -o -path '*/.config/*' \
    -o -path '*/.cache/*' \
    -o -path '*/.cargo/*' \
    -o -path '*/.portage/*' \
    -o -path '*/portage/*' \
    -o -path '*/nix-setup/*' \
    \) -prune -o -type d -name .git -exec dirname {} \;
}

function gp() { # List all functions managed by git and go to it
  cd $(gp_find_cmd | fzf)
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

# Theming the fuzzy finder:
export FZF_DEFAULT_OPTS="
	--color=fg:#e5e9f0,bg:#2e3440,hl:#81a1c1
	--color=fg+:#eceff4,bg+:#434c5e,hl+:#81a1c1
	--color=border:#4c566a,header:#8fbcbb,gutter:#2e3440
	--color=spinner:#ebcb8b,info:#88c0d0
	--color=pointer:#5e81ac,marker:#81a1c1,prompt:#e5e9f0"

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

function show_powerline_char() {
  # Printing the powerline character
  # Unicode entry listed here: https://github.com/ryanoasis/powerline-extra-symbols
  echo '\ue0a0  \ue0a1 \ue0a2 \ue0a3'
  echo '\ue0b0  \ue0b1 \ue0b2 \ue0b3'
  echo '\ue0b4  \ue0b5 \ue0b6 \ue0b7'
}

# Helper functions for getting tmux spin up
if [ ! -z "$CONDA_PREFIX" ]; then # Force reloading conda, ensures tmux internal launch with same conda environment
  conda activate $CONDA_PREFIX
fi

function ctmux() { # For spinning up tmux session in cross-cluster configruations
  $HOME/.config/tmux-plugins-custom/cluster-session/scripts/ctmux attach-session $@
}

function _ctmux() { # Getting the list of managed sessions
  local -a targets
  targets=($($HOME/.config/tmux-plugins-custom/cluster-session/scripts/ctmux list-sessions))
  _arguments -C '1:Select a session:('"${targets[*]}"')'
}
# compdef _ctmux ctmux ## For some reason this must be declared at top level??

#################################################################################
# Functions for setting the title of tabs as they appear in terminal emulators
DISABLE_AUTO_TITLE="true"

function host_display_() {
  if [[ $MACHINE_TYPE_DETAIL == "personal" ]]; then
    echo "🏠"
  elif [[ $MACHINE_TYPE_DETAIL == "kit" ]]; then
    echo "🌐 ${HOST}($MACHINE_TYPE_DETAIL)"
  else
    echo "🌐 ${HOST}"
  fi
}

function precmd() {
  # Determine the string for when the system is idle. The escape string will is
  # used to pass this information to the terminal header handler rather than it
  # being a std streams. Notice that tmux will intrinsically mask this process
  local path_display=$(print -rD $PWD)
  echo -ne "\033]0;$(host_display_)${path_display}\007"
}
precmd

function preexec() {
  # Determining the item for when running a command. This should be transient,
  # and should only be held if there are long running commands that the user
  # should be aware of
  local host=$(host_display_)
  local path_display=$(print -rD $PWD)
  local cmd=""
  # SPeical
  if [[ "$1" == "nvim"* ]]; then
    cmd="🗒️ nvim"
  elif [[ "$1" == "ctmux"* ]]; then
    target=$(echo $1 | awk -F ' ' '{print $2}')
    if [[ $target == "" ]]; then
      target="$(basename $PWD)"
    fi
    cmd="💾 ctmux $target"
    # Overriding host to match the machine that is serving the tmux session
    cache_dir=${CLUSTER_SESSION_TMUX_CACHE_DIR:=$HOME/.local/state/tmux-cluster-session/}
    cache_file=${cache_dir}/tmux.session.${target}
    if [[ -f ${cache_file} ]]; then
      host=$(cat ${cache_file})
    fi
    path_display=""
  else
    cmd="🚀 $1"
  fi
  print -Pn "\e]0;${host}${path_display} | ${cmd}\a"
}

####################################
## Functions for modifying command line behavior

function _add_buffer_prefix() {
  # Function for checking the current working directory, and seeing if command
  # should be augmented by a command prefix

  ## Check if in CMSSW environment
  if command -v cmssw_exec 2>&1 >/dev/null; then
    if [[ $(cmssw_src_path) != "" ]]; then
      echo "cmssw_exec "
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
