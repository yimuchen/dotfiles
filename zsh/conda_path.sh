#

_INSTALL_CONDA_PREFIX=""

if [[ ${HOST} == "ensc"* ]]; then # Personal machine
  _INSTALL_CONDA_PREFIX='/opt/miniconda3'
elif [[ $HOST == "cmslpc"*".fnal.gov" ]] ; then
  _INSTALL_CONDA_PREFIX="/uscms/home/yimuchen/data/miniconda3"
elif [[ $HOST == "hepcms"*".umd.edu" ]] ; then
  _INSTALL_CONDA_PREFIX="/data/users/yichen/miniconda3"
fi

# >>> CONDA SET UP
# !! Contents within this block are taken from example code of conda init
__conda_setup="$(${_INSTALL_CONDA_PREFIX}'/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${_INSTALL_CONDA_PREFIX}/etc/profile.d/conda.sh" ]; then
        . "${_INSTALL_CONDA_PREFIX}/etc/profile.d/conda.sh"
    else
        export PATH="${_INSTALL_CONDA_PREFIX}/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
