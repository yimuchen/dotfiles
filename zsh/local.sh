# Aliases and utility functions specific to personal machines
alias -- efireboot='systemctl reboot --firmware-setup'
alias -- poweroff='systemctl poweroff'
alias -- reboot='systemctl reboot'
alias -- system-config-update='nh os switch --ask $(realpath /etc/nixos/) -- --impure'
alias -- system-update='nh os switch --update --ask $(realpath /etc/nixos/) -- --impure'

# Additional setup for the python session
fpath=(${envpython}/lib/python3.12/site-packages/argcomplete/bash_completion.d "$fpath[@]")
eval "$(cd $HOME/.config/home-manager/bin/local/ && register-python-argcomplete pdftopng.py -s zsh)"
eval "$(cd $HOME/.config/home-manager/bin/local/ && register-python-argcomplete bw_run.py -s zsh)"

function force_ntp_update() {
  # Function to force system clock to be updated using CURL command. This can
  # be used if the NTP protocol port is being block for whatever reason
  sudo date -s "$(curl http://s3.amazonaws.com -v 2>&1 | grep "Date: " | awk '{ print $3 " " $5 " " $4 " " $7 " " $6 " GMT"}')"
}

function firmware_update() {
  # Reminder command for what is needed to get firmware updates
  echo "List available devices:    fwupdmgr get-devices"
  echo "Pull metadata from source: fwupdmgr refresh"
  echo "List available updates:    fwupdmgr get-updates"
  echo "Apply updates:             fwupdmgr update"
}

function root_browse() {
  input="$1"
  if [[ "$input" == *:* ]]; then
    temp_name="/tmp/$(basename "$input")"
    scp "$input" "$temp_name"
    $NIX_EXEC_ROOTBROWSE --web=off "$temp_name"
  else
    $NIX_EXEC_ROOTBROWSE --web=off "$input"
  fi
}
