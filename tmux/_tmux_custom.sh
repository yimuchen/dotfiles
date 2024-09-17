#!/bin/sh

## Helper functions and path definitions
_cache_dir=$HOME/.local/state/tmux/
_log_file=${_cache_dir}/hooks.log

_cache_file() {
  echo ${_cache_dir}/tmux.session.${1}
}

_log() {
  echo "$(date --iso-8601=seconds) | ${@}" >>${_log_file}
}

# Operation - starting a session
session_start() {
  local f=$(_cache_file $1)
  _log "Creating session file ${f}"
  echo $HOSTNAME >$f
}

# Operation - closing a session
session_close() {
  local f=$(_cache_file $1)
  _log "Remove session file $f"
  if [ -f ${f} ]; then
    rm -f ${f}
  fi
}

# Operation renaming a session - TODO: incomplete
session_rename() {
  _log "Renaming session $1"
}

session_rename_post() {
  _log "renaming session (post) $1"
}

# Operation - opening the editor window. The editor window Will always be
# placed in window 1 of the session, and should close immediately if the window
# is closed
editor_window() {
  local session_name=$1
  _log "Checking editor window @ $session_name"
  if ! tmux has-session -t "${session_name}:1" 2>/dev/null; then
    tmux new-window -n "Editor"
    tmux move-window -t ${session_name}:1
    tmux respawn-pane -t ${session_name}:1.0 -k "nvim ."
  fi
}

# Operation - opening the editor window. The editor window Will always be
# placed in window 1 of the session, and should close immediately if the window
# is closed
monitor_window() {
  local session_name=$1
  _log "Checking monitor window @ $session_name"
  if ! tmux has-session -t "${session_name}:2" 2>/dev/null; then
    tmux new-window -n "Monitor"
    tmux move-window -t ${session_name}:2 # Move to second position
  fi
  # Always attempt to respawn the panes
  if ! command -v "condor_q" 2>/dev/null; then
    # No condor related command, spawning simple monitor of htop
    tmux respawn-pane -t ${session_name}:2.0 -k "htop"
  else
    # Assuming local machine
    tmux respawn-pane -t ${session_name}:2.0 -k "htop --user $USER"
    tmux respawn-pane -t ${session_name}:2.1 -k "watch -n 3 \"condor_q -total | grep $USER && condor_q -total | grep 'all user'\""
  fi
}

# Method for spawning and attaching to tmux sessions that can existing in
# different cluster nodes.
dev_tmux() {
  if [ "$#" -ne 1 ]; then
    local session_name=$(basename $PWD)
  else
    local session_name=$1
  fi

  local session_file=$(_cache_file $1)
  if [ -f "${session_file}" ]; then
    # Cache file exists
    local cached_host=$(cat ${session_file})
    if [ "$HOSTNAME" == "${cached_host}" ]; then
      echo "Reattching to local session"
      echo tmux attach -t ${session_name}
    else
      echo "Reattaching over ssh session at machine ${cached_host}"
      local nix_cmd="nix-portable nix shell --offline 'nixpkgs#nix' 'nixpkgs#tmux' --command"
      local tmux_cmd="zsh -c tmux attach -t ${session_name}"
      local ssh_cmd="ssh -F $HOME/.ssh/config -o RequestTTY=yes ${cached_host}"
      echo $ssh_cmd $nix_cmd $tmux_cmd
    fi
  else
    echo "Creating new session ${session_name}"
    echo tmux new -s ${session_name}
  fi
}

# Some preprocessing steps to make sure files/directory exists
if [[ ! -d "${_cache_dir}" ]]; then
  mkdir -p ${_cache_dir}
fi

# Running the input parameters
$@
