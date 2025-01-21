#!/bin/bash

# Configurations variables for the environment.
# Currently there is a bug with all version up to 2027.9.0!!
image_base="/cvmfs/unpacked.cern.ch/registry.hub.docker.com/"
image_version="coffeateam/coffea-dask-almalinux8:2024.8.1-py3.11"

# Below are not longer configurations, do not modify unless you know what you
# are doing.
env_name=."$(basename $PWD)" # Find a way to detect if a valid environment file exists?
ext_base=$(realpath $PWD)
wrk_base="/srv"
image_source=${image_base}/${image_version}
bash_env_file=.bashenv

# Additional variables to be loaded in the apptainer environment
touch ${bash_env_file}
cat >"${bash_env_file}" <<EOF
# Setting up jupyter methods
export JUPYTER_PATH=${wrk_base}/.jupyter
export JUPYTER_RUNTIME_DIR=${wrk_base}/.local/share/jupyter/runtime
export JUPYTER_DATA_DIR=${wrk_base}/.local/share/jupyter
export IPYTHONDIR=${wrk_base}/.ipython
# Setting up variables required for running condor
export CONTAINER_HOST_BASEPATH=${ext_base}
export CONTAINER_WORKPATH=${wrk_base}


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/etc/profile.d/conda.sh" ]; then
        . "/usr/local/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Setting up the python environment if it doesn't already exist
if [[ ! -d $HOME/.conda/envs/${env_name} ]]; then
  echo "Building the virtual environment"
  conda create -n ${env_name} -y 2>&1 > /dev/null
fi
conda activate ${env_name}
EOF

# Machine specific configurations
export APPTAINER_BINDPATH=${CMSSW_APPTAINER_BINDPATH}

# Running the apptainer command
if [ $# -eq 0 ]; then
  apptainer exec -p \
    -B ${PWD}:${wrk_base} --pwd ${wrk_base} \
    ${image_source} \
    /bin/bash --rcfile ${wrk_base}/${bash_env_file}
else
  cmd_run="$(echo $@)" # Condensing commands into a single string
  unset BASH_ENV
  apptainer exec -p \
    -B ${PWD}:${wrk_base} --pwd ${wrk_base} \
    --env "BASH_ENV=${wrk_base}/${bash_env_file}" \
    ${image_source} \
    /bin/bash -c "$cmd_run"
fi
