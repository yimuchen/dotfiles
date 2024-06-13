# Configuration for tmux for multiplexing and sessiong saving

{ pkgs, config, ... }: {
  home.packages = [
    pkgs.tmux # For multiplexing and session saving
  ];
  # Link to the major configuration path
  home.file.".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/tmux.conf";
}

