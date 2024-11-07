{ pkgs, config, ... }:
let
  # Forcing the system time update in case the NTP connection fails for whatever reason
  force_ntp_update = pkgs.writeShellApplication {
    name = "force_ntp_update";
    text = # bash
      ''
        sudo date -s "$(curl http://s3.amazonaws.com -v 2>&1 |  grep "Date: " | awk '{ print $3 " " $5 " " $4 " " $7 " " $6 " GMT"}')"
      '';
  };

  # Listing the commands required for updating firmware. Explicitly not running automatically
  firmware_update = pkgs.writeShellApplication {
    name = "firmware_update";
    text = # bash
      ''
        echo "List available devices:    fwupdmgr get-devices"
        echo "Pull metadata from source: fwupdmgr refresh"
        echo "List available updates:    fwupdmgr get-updates"
        echo "Apply updates:             fwupdmgr update"
      '';
  };
in {
  # Additional helper methods for system helping
  programs.zsh.shellAliases = {
    # Power related aliases
    "poweroff" = "systemctl poweroff";
    "reboot" = "systemctl reboot";
    "efireboot" = "systemctl reboot --firmware-setup";
  };

  home.packages = [ force_ntp_update firmware_update ];
}
