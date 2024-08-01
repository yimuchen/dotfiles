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
      enable = true;
      plugins = [
        "romkatv/powerlevel10k" # For the theming
        "conda-incubator/conda-zsh-completion.git" # For conda autocomplete
      ];
    };
  };
  # Package management is mainly handled by a automatic pull of oh-my-zsh

  home.file = {
    # My configuration files
    #".zshrc".source = config.lib.file.mkOutOfStoreSymlink
    #  "${config.home.homeDirectory}/.config/home-manager/zsh/zshrc.zsh";
    #".zsh".source = config.lib.file.mkOutOfStoreSymlink
    #  "${config.home.homeDirectory}/.config/home-manager/zsh";
  };
}
