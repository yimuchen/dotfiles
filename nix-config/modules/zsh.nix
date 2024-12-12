{ pkgs, config, ... }: {
  # Configuration of ZSH environment. Here we most of the configurations here
  # should be either simple signal lines augmentation of standard coreutils
  # items. For items for complicated, it should either be placed in the
  # shell-helper modules if the helper uses non-coreutils packages; or in the
  # zsh/common_utils.sh file for standard zsh tools
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = # bash
      ''
                # Enabling the autocomplete script. This is very slow on Nix systems so
                # setting this to only run once per day
                autoload -Uz compinit
                if [[ $(($(date +%s) - $(stat -c "%Y" $HOME/.zcompdump))) -gt 86400 ]]; then
        	        compinit;
                else
        	        compinit -C;
                fi;
      '';
    syntaxHighlighting = { enable = true; };
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
        # Uncomment to enable profiling
        # zmodload zsh/zprof
        # Instant prompt for powerlevel10k
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
    # Adding to the end of zshrc
    initExtra = # bash
      ''
        # Setting the theme of the prompt
        source "$HOME/.config/zsh/p10k.zsh"
        # Additional settings for specific machines (must be loaded after the p10k configuration)
        source "$HOME/.config/zsh/machine.sh"
        # Additional command-line tools that uses common gnu-coreutils tools
        source "$HOME/.config/zsh/common_utils.sh"

        # Uncomment to run profiling
        # zprof
      '';
    shellAliases = {
      # Simple aliases of in-built shell functions
      "ln" = "ln --symbolic --force";
      "ls" = "ls --group-directories-first -X --human-readable --color=auto";
      "grp" = "grep --colour=always";
      "ping" = "ping -c 7 -i 0.200";
      "ping-test" = "ping www.google.com";
      "rm" = "rm -i";
      "dir_size" =
        "du --max-depth=1 --human-readable --all | sort --human-numeric-sort";
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

      # Additional aliases with package methods (the root package should be
      # handled by the environment of interest and not by nix
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
      "${config.home.homeDirectory}/.config/home-manager/nix-config/devshells";
  };
}
