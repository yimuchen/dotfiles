#!/bin/sh

## Helper functions and path definitions
_cache_dir=$HOME/.local/state/tmux/
_log_file=${_cache_dir}/hooks.log

_cache_file() {
  echo ${_cache_dir}/tmux.session.${1}
}

_log() {
  echo "$(date --iso-8601=seconds) | ${@}" >>${_log_file}
  # Truncate to at most 1000 lines
  tail -n 1000 ${_log_file} > ${_log_file}.tmp
  mv -f ${_log_file}.tmp  ${_log_file}
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

# Operation - opening the explore window, this is just a default shell window
# the we will always either keep open, or reopen if accidentally closed
explore_window() {
  local session_name=$1
  local window_index=${session_name}:0
  _log "Checking explore window @ ${window_index}"

  if ! tmux has-session -t "${window_index}" 2>/dev/null; then
    tmux new-window -n "Explore" -t ${window_index}
  fi
  tmux rename-window -t ${window_index} "Explore"
}

# Operation - opening the editor window. The editor window Will always be
# placed in window 1 of the session, and should close immediately if the window
# is closed
_editor_idx() {
  echo "${1}:1"
}

editor_window() {
  local editor_idx=$(_editor_idx $1)
  _log "Checking editor window @ ${editor_idx}"
  if ! tmux has-session -t "${editor_idx}" 2>/dev/null; then
    tmux new-window -n "Editor" -t "${editor_idx}"
    # When closing the editor, always try to close the repl pane to ensure the
    # editor is always pane 0
    tmux respawn-pane -t ${editor_idx}.0 -k "nvim . && ~/.config/tmux/_tmux_custom.sh _close_repl_pane $1"
  fi
}

# Operation - spawning a REPL interaction terminal with the same window as the
# editor window - 1.1, or in the case that it is sent to the background, it
# will be sent to window 9.0. As this window can be toggled on or off,
# additional helper function is needed.
_repl_active_idx() {
  echo "$(_editor_idx $1).1"
}
_repl_bkg_win() {
  echo "${1}:9"
}
_repl_bkg_pane() {
  echo "$(_repl_bkg_win).0"
}

_open_repl_pane() {
  _log "Checking if the editor window does has a REPL session"
  # Always open the editor_window first
  editor_window

  local editor_idx=$(_editor_idx $1)
  local repl_active=$(_repl_active_idx $1)
  local repl_bkg=$(_repl_bkg_pane $1)

  if ! tmux has-session -t ${repl_active} 2> /dev/null ; then
    if tmux has-session -t ${repl_bkg} 2> /dev/null ; then
      _log "Moving background window to session"
      tmux join-pane -s ${repl_bkg} -t "${editor_idx}" -h -l 80
    else
      _log "Creating the new pane directly in the pane"
      tmux split-window -t ${editor_idx} -h -l 80
      # Forcing the 
      tmux resize-pane -t "${repl_active}" -x 80 
      _log "Respawn pane with repl script ${PWD}/.repl.sh"
      if [[ -f "$PWD/.repl.sh" ]]; then
        echo "Launching repl interactive script ${PWD}/.repl.sh"
        tmux respawn-pane -t ${repl_active} -k "${PWD}/.repl.sh"
      else
        echo "Did not find repl interactive script ${PWD}/.repl.sh"
      fi
    fi
  fi
  # Resizing horizontal width
  # Keep focus on primary editor window
  tmux select-pane -t ${editor_idx}.0
}

_close_repl_pane() {
  _log "Sending REPL pane to background if it already exists"
  editor_window

  local repl_active=$(_repl_active_idx $1)
  local repl_bkg=$(_repl_bkg_win $1)

  if tmux has-session -t ${repl_active} 2>/dev/null ; then
    # -d To not focus on this this new pane
    _log "Moving pane back background window"
    tmux break-pane -d -s "${repl_active}" -t "${repl_bkg}"
    tmux rename-window -t "${repl_bkg}" "(repl-bkg)"
  fi
}

_toggle_repl_pane() {
  _log "Toggling repl window relative to the editor window"
  if ! tmux has-session -t "$(_repl_active_idx $1)" 2> /dev/null ; then
    _open_repl_pane "${1}"
  else
    _close_repl_pane "${1}"
  fi
}

_guard_repl_bkg() {
  if ! tmux has-session -t "$(_repl_bkg_win $1)" 2> /dev/null ; then
    tmux display-message -p "Window 9 is reserved for the REPL terminal instance"
  fi
}


# Operation - opening the monitor window. The monitor window will always be
# placed in window 1 of the session, and should close immediately if the window
# is closed
monitor_window() {
  local session_name=$1
  _log "Checking monitor window @ $session_name"
  if ! tmux has-session -t "${session_name}:2" &>/dev/null; then
    tmux new-window -n "Monitor" -t ${session_name}:2
  fi
  # Always attempt to respawn the panes
  if ! command -v "condor_q" &>/dev/null; then
    # No condor related command, spawning simple monitor of htop
    tmux respawn-pane -t ${session_name}:2.0 -k "htop"
  else
    if ! tmux has-session -t "${session_name}:2.1" &> /dev/null ; then
      tmux split-window -t ${session_name}:2
      tmux resize-pane -t ${session}:2.0 -y 10
    fi
    tmux respawn-pane -t ${session_name}:2.0 -k "watch -n 3 \"condor_q -total | grep $USER && condor_q -total | grep 'all user'\""
    tmux respawn-pane -t ${session_name}:2.1 -k "htop --user"
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

  local session_file=$(_cache_file $session_name)
  if [[ -f "${session_file}" ]]; then
    # Cache file exists
    local cached_host=$(cat ${session_file})
    if [ "$HOSTNAME" == "${cached_host}" ]; then
      # "Reattaching to local session"
      _log "[DEV_TMUX] Attaching to session ${session_name}"
      tmux attach-session -t ${session_name}
    else
      _log "[DEV_TMUX] Attaching to session ${session_name}@${cached_host}}"
      # "Reattaching over ssh session at machine
      local nix_cmd="nix-portable nix shell --offline 'nixpkgs#nix' 'nixpkgs#tmux' --command"
      local tmux_cmd="zsh -c \"tmux attach-session -t ${session_name}\""
      local ssh_cmd="ssh -F $HOME/.ssh/config -o RequestTTY=yes ${cached_host}"
      $ssh_cmd $nix_cmd $tmux_cmd
    fi
  else
    # Creating new session
    _log "[DEV_TMUX] create new session ${session_name}"
    tmux new -s ${session_name}
  fi
}

# Some preprocessing steps to make sure files/directory exists
if [[ ! -d "${_cache_dir}" ]]; then
  mkdir -p ${_cache_dir}
fi

# Running the input parameters
$@
