{ config, ... }: {
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
  };

  home.file = {
    # My configuration files
    ".config/zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/zsh";
    #".zsh".source = config.lib.file.mkOutOfStoreSymlink
    #  "${config.home.homeDirectory}/.config/home-manager/zsh";
  };
}
