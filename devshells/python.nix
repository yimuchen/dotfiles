{ pkgs, ... }:
(pkgs.mkShell {
  name = "Development environment for python. Requires a environment.yaml file to be present";
  packages = [
    pkgs.micromamba # For setting up the development environments
    pkgs.yq-go # For getting the information from the environment yaml
  ];

  shellHook = ''
    set -e
    eval "$(micromamba shell hook -s zsh)" # Setting the various items off
    # Setting the envrionment to be a local path
    if [ -z "$MAMBA_ROOT_PREFIX" ]; then
      echo "Envrionment variable MAMBA_ROOT_PREFIX must be defined"
      exit 127
    fi
    if [[ ! -f $PWD/environment.yaml ]]; then
      echo "[environment.yaml] file was not defined"
      exit 127
    fi
    # Create the environment if the directory doesn't already exist
    ENV_NAME=$(yq ".name" environment.yaml)
    if [[ ! -d $MAMBA_ROOT_PREFIX/envs/$ENV_NAME ]]; then
      echo "Creating envrionment directory..."
      micromamba create -f environment.yaml -y > /dev/null
    fi
    # Always attempt to update the environment
    micromamba activate $ENV_NAME
    echo "Updating environment..."
    micromamba install --name $ENV_NAME -f environment.yaml -y > /dev/null
    # Additional update if a additional developement yaml file exists
    echo "Installing development packages ..."
    micromamba install --name $ENV_NAME -f $DEFAULT_DEVSHELL_STORE/dev_python_environment.yaml -y > /dev/null
    # Showing some additional information
    echo "Python executable:" $(which python) $(python --version)
    python -m ipykernel install --user --name $ENV_NAME
  '';
})
