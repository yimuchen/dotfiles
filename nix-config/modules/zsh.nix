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
    dotDir = "${config.home.homeDirectory}/.config/zsh";
  };
  # Package management is mainly handled by a automatic pull of oh-my-zsh

  home.file = {
    # My configuration files
    ".config/zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/zsh";
    #".zsh".source = config.lib.file.mkOutOfStoreSymlink
    #  "${config.home.homeDirectory}/.config/home-manager/zsh";
  };
}
