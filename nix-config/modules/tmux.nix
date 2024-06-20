# Configuration for tmux for multiplexing and sessiong saving

{ pkgs, config, ... }: {
  programs.tmux = {
    enable = true;
    newSession = true; # Spawn new session in nothing is running
    terminal = "xterm-256color";
    plugins = [ # Plugins listed in the official nix repository
      {
        plugin = pkgs.tmuxPlugins.rose-pine; # For theming
        extraConfig = ''
          set -g @rose_pine_variant 'main'
          set -g @rose_pine_host 'on' # Enables hostname in the status bar
          set -g @rose_pine_user 'on' # Turn on the username component in the statusbar
          set -g @rose_pine_directory 'on'
        '';
      }
    ];
    extraConfig = ''
      set -g allow-passthrough on # Allowing passthrough
      bind-key -T  prefix N new-window "zsh -c 'nvim .'"
      bind-key -T  prefix M new-window "htop --user $USER"
    '';
  };
}

