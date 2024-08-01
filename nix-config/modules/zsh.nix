{ pkgs, config, ... }: {
  # Additional packages that is required to use the various configuration.
  # Because zsh should be considered a system package, do *not* put zsh here.

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      # Additional theming?
    };
    syntaxHighlighting = {
      enable = true;
      # Additional theming??
    };
    antidote = {
      # Primary plugin manager (as this doesn't require version pinning)
      enable = true;
      plugins = [
        "romkatv/powerlevel10k" # For the theming
        "conda-incubator/conda-zsh-completion.git" # For conda autocomplete
      ];
    };
    # Effectively Superceding the role of zshrc
    envExtra = ''
      # Additional theme settings is stored in p10k.zsh
      source $HOME/.config/zsh/p10k.zsh
      # Additional machine-specific settings
      source $HOME/.config/zsh/machine.sh
    '';
    shellAliases = {
      # Simple aliases of in-built shell functions
      "ln" = "ln --symbolic --force";
      "ls" = "ls --group-directories-first -X --human-readable --color=auto";
      "grp" = "grep --colour=always";
      "ping" = "ping -c 7 -i 0.200";
      "ping-test" = "ping www.google.com";
      "rm" = "rm -i";
      "dir_size" = "du --max-depth=1 --human-readable --all | sort -h";
      "less" = "less --raw-control-chars";
      "wget" = "wget --continue";
      # Additional aliases with package methods
      "root" = "${pkgs.root}/bin/root -l"; # CERN ROOT
    };
  };

  home.file = {
    # Additional configuration files requires shell scripting
    ".config/zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/zsh";
  };
}
