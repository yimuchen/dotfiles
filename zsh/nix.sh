# Avoid double sourcing, (important for nix developement shells)
if [ -n "$__HM_SESS_VARS_SOURCED" ]; then return; fi

# Setting the path defined by home-manager
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
export PATH=$HOME/.nix-profile/bin/:$PATH

# Alias for starting a development shell with zsh (nix defaults to bash)
alias nshell="nix develop -c $SHELL"
