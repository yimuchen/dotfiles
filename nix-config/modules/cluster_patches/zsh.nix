{ config, pkgs, ... }: {
  # Removing all autocompletes that were defined by the system
  programs.zsh.initExtraBeforeCompInit = # bash
    ''
      fpath=()
      for profile in $HOME/.nix-profile; do
        fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
      done
    '';
}

