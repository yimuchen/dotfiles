# Alias
alias -- ssh='ssh -F ~/.ssh/config'

# Additional configuration to ensure that the customized ctmux command will
# generate a custom command to account for the nix/zsh environment
export CLUSTER_SESSION_TMUX_SSH_ARGS="-R 9543:localhost:9543"
export CLUSTER_SESSION_TMUX_REMOTE_TMUX_CMD=".portage/usr/bin/tmux attach-session -t __SESSION_NAME__"

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
  emaint --auto sync
  emerge --ask --verbose --update --deep --newuse @world
  emerge --depclean
}
