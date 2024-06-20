# NIX Configurations for zsh. Due to the complexity of the configuration, the
# main configuration will still use the nix-less methods. Nix is just
# responsible for setting up the symbolic link in the home directory.
{ config, ... }: {
  # Additional packages that is required to use the various configuration.
  # Because zsh should be considered a system package, do *not* put zsh here.

  # Package management is mainly handled by a automatic pull of oh-my-zsh
  home.file = {
    ".oh-my-zsh".source = builtins.fetchGit {
      url = "https://github.com/ohmyzsh/ohmyzsh";
      ref = "master";
    };
    # Custom zsh plugins
    ".omz-custom/plugins/conda-zsh-completion".source = builtins.fetchGit {
      url = "https://github.com/conda-incubator/conda-zsh-completion.git";
      ref = "main";
    };
    #  The powerline 10 theme
    ".omz-custom/themes/powerlevel10k".source = builtins.fetchGit {
      url = "https://github.com/romkatv/powerlevel10k.git";
      ref = "master";
    };

    # My configuration files
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/zsh/zshrc.zsh";
    ".zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/zsh";
  };
}
