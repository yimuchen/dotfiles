# Alias
alias -- ssh='ssh -F ~/.ssh/config'

# Making sure the remote session understands ghostty
export TERMINFO=$HOME/.terminfo

# Additional configuration to ensure that the customized ctmux command will
# generate a custom command to account for the nix/zsh environment
export CLUSTER_SESSION_TMUX_SSH_ARGS="-R 9543:localhost:9543"
export CLUSTER_SESSION_TMUX_REMOTE_TMUX_CMD=".portage/usr/bin/tmux attach-session -t __SESSION_NAME__"

# Loading additional tools that are available on the server dies
if [[ "$MACHINE_TYPE_DETAIL" == "cmslpc" ]]; then
  source /etc/profile.d/eos_aliases.sh
fi

function cert_cern_gen() {
  # Helper commands for a way to consistently generate user tokens that is
  # required for analysis work.
  if [ "$#" -ne 1 ]; then
    echo "Download your certificate at https://ca.cern.ch/ca/user/Request.aspx?template=EE2User"
    echo "Then run the command like: cert_cern_gen MY_CERTIFICATE.p12"
  else
    openssl pkcs12 -in "$1" -clcerts -nokeys -out "$HOME/.globus/usercert.pem"
    chmod 644 "$HOME/.globus/usercert.pem"
    openssl pkcs12 -in "$1" -nocerts -out "$HOME/.globus/userkey.pem"
    chmod 600 "$HOME/.globus/userkey.pem"
  fi
}

function environment_update() {
  # Upgrading everything that is managed by the gentoo/emerge
  if [[ $MACHINE_TYPE_DETAIL == "lxplus" ]]; then
    mkdir -p /tmp/$USER/portage/var/lib/portage
    mv $HOME/.portage/var/lib/portage/* /tmp/$USER/portage/var/lib/portage
    rm -rf $HOME/.portage/var/lib/portage/
    ln -sf /tmp/$USER/portage/var/lib/portage $HOME/.portage/var/lib
  fi
  emaint --auto sync
  emerge --ask --verbose --update --deep --newuse @world
  emerge --depclean
  if [[ $MACHINE_TYPE_DETAIL == "lxplus" ]]; then
    rm $HOME/.portage/var/lib/portage
    mkdir -p $HOMR/.portage/var/lib/portage
    mv /tmp/$USER/portage/var/lib/portage $HOME/.portage/var/lib/portage
  fi
  # Upgrading everything that is managed by python-uv
  if [[ ! -d $HOME/.cli-python ]]; then
    uv venv --system-site-packages $HOME/.cli-python
  elif [[ ! -f $(realpath $HOME/.cli-python/bin/python) ]]; then
    uv venv --system-site-packages $HOME/.cli-python
  fi
  VIRTUAL_ENV=$HOME/.cli-python uv pip install --upgrade --requirements $HOME/tools_config/pkg/cli-python-remote.txt

  # Cargo package management
  if [[ ! -f $HOME/bin/cargo-install-update ]]; then
    cargo install cargo-update
  fi
  # Ensure everything is installed
  cargo install $(cat $HOME/tools_config/pkg/cli-cargo-remote.txt) --locked
  # Update all cargo tools
  cargo install-update -a
}
