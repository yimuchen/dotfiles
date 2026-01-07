#!/bin/bash

CONDOR_SUMMARY_JSON=$HOME/.local/state/tmux/condor_summary.json

if command -v condor_q &>/dev/null; then
  prev=0
  if [ -f ${CONDOR_SUMMARY_JSON} ]; then
    prev=$(stat --format="%Y" ${CONDOR_SUMMARY_JSON})
  fi
  cur=$(date "+%s")
  if [[ $(($cur - $prev)) -gt 30 ]]; then
    condor_q -totals -json >${CONDOR_SUMMARY_JSON}
  fi
  # Parsing json file for results
  idle_all=$(jq '[.[].AllusersIdle] | add' ${CONDOR_SUMMARY_JSON})
  idle_usr=$(jq '[.[].MyIdle] | add' ${CONDOR_SUMMARY_JSON})
  run_all=$(jq '[.[].AllusersRunning] | add' ${CONDOR_SUMMARY_JSON})
  run_usr=$(jq '[.[].MyRunning] | add' ${CONDOR_SUMMARY_JSON})
  held_all=$(jq '[.[].AllusersHeld] | add' ${CONDOR_SUMMARY_JSON})
  held_usr=$(jq '[.[].MyHeld] | add' ${CONDOR_SUMMARY_JSON})
  # Echo printing the solution
  echo " 󰙮 │ 󱇼 ${idle_usr}/${idle_all} 󰯔 ${run_usr}/${run_all} 󰾘 ${held_usr}/${held_all} "
fi
