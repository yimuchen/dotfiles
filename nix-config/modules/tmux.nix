{ pkgs, config, ... }:
let
  dotfile_dir = "${config.home.homeDirectory}/.config/home-manager";
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
    newSession = true; # Spawn new session in nothing is running
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
        # Hooks for handling cluster tmux
        set-hook -g session-created      "run-shell \"$HOME/.config/tmux/_tmux_custom.sh session_start       #{hook_session_name}\""
        set-hook -g session-closed       "run-shell \"$HOME/.config/tmux/_tmux_custom.sh session_close       #{hook_session_name}\""
        set-hook -g session-renamed      "run-shell \"$HOME/.config/tmux/_tmux_custom.sh session_rename      #{hook_session_name}\""
        set-hook -g after-rename-session "run-shell \"$HOME/.config/tmux/_tmux_custom.sh session_rename_post #{hook_session_name}\""
        # Spawning "standard windows"
        bind-key 1 "run-shell \"$HOME/.config/tmux/_tmux_custom.sh editor_window  #{session_name}\"\; select-window -t 1"
        bind-key e "run-shell \"$HOME/.config/tmux/_tmux_custom.sh editor_window  #{session_name}\"\; select-window -t 1"
        bind-key 2 "run-shell \"$HOME/.config/tmux/_tmux_custom.sh monitor_window #{session_name}\"\; select-window -t 2"
        bind-key m "run-shell \"$HOME/.config/tmux/_tmux_custom.sh monitor_window #{session_name}\"\; select-window -t 2"
      '';
  };
  home.file.".config/tmux/_tmux_custom.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfile_dir}/tmux/_tmux_custom.sh";
  home.packages = [ dev-tmux ];
}

