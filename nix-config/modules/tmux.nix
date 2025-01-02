{ pkgs, config, ... }:
let
  makeln = config.lib.file.mkOutOfStoreSymlink;
  hm_config = "${config.home.homeDirectory}/.config/home-manager/config";
  # A simple script to spawn a development tmux session that can be traced
  # across cluster nodes
  dev-tmux = pkgs.writeShellApplication {
    name = "dev-tmux";
    text = # bash
      ''
        "$HOME/.config/tmux/_tmux_custom.sh" dev_tmux "$@"
      '';
  };

in {
  # Configuration for tmux for multiplexing and session saving
  programs.tmux = {
    enable = true;
    newSession = false; # Spawn new session in nothing is running
    historyLimit = 1000000; # Expanding the history limit
    terminal = "xterm-256color";
    plugins = [ # Plugins listed in the official nix repository
      {
        plugin = pkgs.tmuxPlugins.rose-pine; # For themeing
        extraConfig = ''
          set -g @rose_pine_variant 'main'
          set -g @rose_pine_host 'on' # Enables hostname in the status bar
          set -g @rose_pine_user 'on' # Turn on the username component in the statusbar
          set -g @rose_pine_directory 'on'
        '';
      }
    ];
    # Because custom tmux parsing methods are rather complicated and we would
    # likely want to adjust these one the fly, we will be using saving these to a
    # custom .sh file in the tmux directory
    extraConfig = # bash
      ''
        source-file ${config.home.homeDirectory}/.config/tmux/config_extra.conf
      '';
  };
  home.file.".config/tmux/_tmux_custom.sh".source =
    makeln "${hm_config}/tmux/_tmux_custom.sh";
  home.file.".config/tmux/config_extra.conf".source =
    makeln "${hm_config}/tmux/config_extra.conf";
  home.packages = [ dev-tmux ];
}

