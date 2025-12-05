#!/bin/sh

# Operation - opening the explore window, this is just a default shell window
# the we will always either keep open, or reopen if accidentally closed
explore_window() {
  local session_name=$1
  local window_index=${session_name}:0

  explore_title=${TMUX_EXPLORE_TITLE:-Explore}
  if ! tmux has-session -t "${window_index}" 2>/dev/null; then
    tmux new-window -n "${explore_title}" -t ${window_index}
  fi
  tmux rename-window -t ${window_index} "${explore_title}"
}

# Operation - opening the editor window. The editor window Will always be
# placed in window 1 of the session, and should close immediately if the window
# is closed
_editor_idx() {
  echo "${1}:1"
}

editor_window() {
  local editor_idx=$(_editor_idx $1)
  if ! tmux has-session -t "${editor_idx}" 2>/dev/null; then
    editor_title="${TMUX_EDITOR_TITLE:-Editor}"
    tmux new-window -n "${editor_title}" -t "${editor_idx}"
    # When closing the editor, always try to close the repl pane to ensure the
    # editor is always pane 0
    tmux respawn-pane -t ${editor_idx}.0 -k "zsh  --login -c 'nvim .'"
  fi
}

# Running the input parameters
$@
