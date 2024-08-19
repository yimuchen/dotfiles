{ pkgs, config, ... }: {
  # Additional helper methods for system helping
  programs.zsh.shellAliases = {
    # Power related aliases
    "poweroff" = "systemctl poweroff";
    "reboot" = "systemctl reboot";
    "efireboot" = "systemctl reboot --firmware-setup";
  };
}
