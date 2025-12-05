#!/bin/bash
# Helper function for getting tmux uptime
if [[ ! -z $TMUX ]]; then
  start=$(stat --format="%W" ${TMUX/,*/})
  current=$(date +%s)
  diff=$(($current - $start))
  # Solution from: https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
  date -ud "@$diff" +"$(($diff / 3600 / 24))d %H:%M"
fi
