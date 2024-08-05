{ pkgs, config, ... }: {
  # Additional paths for fixing the certain executable paths for system still
  # using stand-alone home-manager instances
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";
  programs.zsh.initExtra = ''
    export PATH=$PATH:$HOME/.nix-profile/bin/
  '';
}
