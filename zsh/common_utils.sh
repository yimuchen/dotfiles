# Utility function for interacting with the system

#-----  Common alias list ------------------------------------------------------
alias ln='ln --symbolic --force'
alias ls='ls --group-directories-first -X --human-readable --color=auto'
alias grp='grep --colour=always'
alias ping='ping -c 7 -i 0.200'
alias ping-test='ping www.google.com'
alias rm='rm -i'
#alias visudo='EDITOR=vim visudo'
alias size='du --max-depth=1 --human-readable --all | sort -h'
alias less='less --raw-control-chars'
alias root='root -l' # CERN ROOT
alias wget='wget --continue'
alias tmux="TERM=screen-256color-bce tmux"
alias ssh='ssh -Y'
alias less='less -R'

#---- Additional utility function
function get_jupyter_url() {
   # Getting the url of the of the jupyter server session that is running in this
   # directory
   local json_file=$(ls -1t ${PWD}/.local/share/jupyter/runtime/jpserver-*.json | head -n 1)
   local token=$(jq -r '.token' ${json_file})
   local port=$(jq -r '.port' ${json_file})
   # Assuming that localhost is used to expose the runtime
   echo "http://localhost:${port}/?token=${token}"
}

function cert_gen_cmd() {
   ## Printing the command to generate certificate generation on screen
   echo "You can get your certificate at: https://ca.cern.ch/ca/user/Request.aspx?template=EE2User"
   echo "Below ar the commands using the certificate:"
   echo ">> openssl pkcs12 -in <MyCert.p12> -clcerts -nokeys -out \$HOME/.globus/usercert.pem"
   echo ">> openssl pkcs12 -in <MyCert.p12> -nocerts -out \$HOME/.globus/userkey.pem"
}
