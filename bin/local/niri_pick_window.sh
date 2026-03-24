#!/bin/bash
windows=$(niri msg -j windows)
fuzzel_id=$(echo "${windows}" | jq -r 'map("\(.app_id) | \(.title // .app_id)\u0000icon\u001f\(.app_id)") | .[]' | fuzzel --dmenu --index)
focus_id=$(echo "${windows}" | jq ".[${fuzzel_id}].id")
niri msg action focus-window --id ${focus_id}
