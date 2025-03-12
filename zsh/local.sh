# Aliases and utility functions specific to personal machines
alias -- efireboot='systemctl reboot --firmware-setup'
alias -- poweroff='systemctl poweroff'
alias -- reboot='systemctl reboot'

# Additional setup for the python session
NIX_ENVPYTHON_DIR=$(dirname $(dirname $(realpath $(which python))))
ENVPYTHON_VERSION=$(python --version | awk '{print $2}' | cut -f1,2 -d'.')
fpath=(${NIX_ENVPYTHON_DIR}/lib/python${ENVPYTHON_VERSION}/site-packages/argcomplete/bash_completion.d "$fpath[@]")
eval "$(cd $HOME/.config/dot-bin/local/ && register-python-argcomplete pdftopng.py -s zsh)"
eval "$(cd $HOME/.config/dot-bin/local/ && register-python-argcomplete bw_run.py -s zsh)"

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

function system_update() {
  sudo decman --source $HOME/configurations/systems/decman-source.py
}

EXEC_ROOTBROWSE="${NIX_EXEC_ROOTBROWSE:=rootbrowse}"
function root_browse() {
  input="$1"
  if [[ "$input" == *:* ]]; then
    temp_name="/tmp/$(basename "$input")"
    scp "$input" "$temp_name"
    $EXEC_ROOTBROWSE --web=off "$temp_name"
  else
    $EXEC_ROOTBROWSE --web=off "$input"
  fi
}

# Enabling conda if it exists
if [[ -f /opt/miniconda3/etc/profile.d/conda.sh ]]; then
  source /opt/miniconda3/etc/profile.d/conda.sh
fi
