{ pkgs, config, ... }: {
  # Additional packages that is required to use the various configuration.
  # Because zsh should be considered a system package, do *not* put zsh here.

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      # Additional theming??
    };
    antidote = {
      # Primary plugin manager (as this doesn't require version pinning)
      enable = true;
      plugins = [
        "romkatv/powerlevel10k" # For the GUI theme
        "conda-incubator/conda-zsh-completion.git" # For conda auto-complete
      ];
    };
    # Adding to the front of zshrc for instant prompting
    initExtraFirst = # bash
      ''
        # Instant prompt for powerlevel10k
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
    # Adding to the end of zshrc
    initExtra = # bash
      ''
        # Additional settings for specific machines
        source "$HOME/.config/zsh/machine.sh"
        # Additional theme settings for in p10k.zsh
        source "$HOME/.config/zsh/p10k.zsh"
        # Additional command-line tools that uses common gnu-coreutils tools
        source "$HOME/.config/zsh/common_utils.sh"
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

      # Additional tools with nix shell
      "nshell" = "nix develop -c $SHELL";
      "nshell-py3p10" =
        "nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#python-3p10";
      "nshell-py3p11" =
        "nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#python-3p11";
      "nshell-py3p12" =
        "nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#python-3p12";
      "nshell-lua" =
        "nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#lua -c $SHELL";
      "nshell-tex" =
        "nix develop $(realpath $DEFAULT_DEVSHELL_STORE)#tex -c $SHELL";

      # Additional aliases with package methods
      "root" = "root -l"; # CERN ROOT
    };
  };

  # Additional configuration files requires shell scripting
  home.file = {
    ".config/zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/zsh";
  };

  # Additional variables required for the aliases
  home.sessionVariables = {
    DEFAULT_DEVSHELL_STORE =
      "${config.home.homeDirectory}/.config/home-manager/devshells";
  };
}
