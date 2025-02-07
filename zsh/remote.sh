# Alias
alias -- home-config-update='nh home switch --ask $(realpath $HOME/.config/home-manager)'
alias -- home-update='nh home switch --update --ask $(realpath $HOME/.config/home-manager)'
alias -- ssh='ssh -F ~/.ssh/config'

function cert_cern_gen() {
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
