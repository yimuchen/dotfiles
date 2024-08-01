{ pkgs, pyversion, ... }:
let
  python_fhs = pkgs.buildFHSUserEnv {
    name = "python_fhs";
    description = ''
      Simple development environment for pure python. This will attempt to
      create a global conda environment base on the current working directory.
      I prefer global condas, as this means that the working directory will
      remain clean and easy to pass between machines.
    '';

    targetPkgs = _: [ pkgs.micromamba ];

    profile = ''
      set -e
      eval "$(micromamba shell hook --shell=posix)"
      ENV_NAME="$(basename $PWD)"-py${pyversion}

      if [[ ! -d $MAMBA_ROOT_PREFIX/envs/$ENV_NAME ]] ;  then
        echo "Creating conda (micromamba) environment"
        micromamba create  --yes -q --name $ENV_NAME -c conda-forge python=${pyversion}
        micromamba activate $ENV_NAME
        python -m pip install -r $DEFAULT_DEVSHELL_STORE/dev_conda.txt
        python -m pip install -r $DEFAULT_DEVSHELL_STORE/dev_pip.txt
      else
        micromamba activate $ENV_NAME
      fi
      set +e
    '';
    runScript = "zsh";
  };
in python_fhs.env
