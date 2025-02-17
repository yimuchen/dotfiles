{ pkgs, config, ... }:
let
  hm_binlocal = "${config.home.homeDirectory}/.config/home-manager/bin/local/";
in {
  # Configurations related to systemd services that we want to enable on
  # personal systems

  # Syncthings services
  services.syncthing = {
    enable = true;
    extraOptions = [
      "--gui-address=127.0.0.1:8000" # Using port 8000
    ];
  };

  # A global language tool instance
  systemd.user.services.languagetool = {
    Unit = { Description = "Starting the languagetool server"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      ExecStart =
        "${pkgs.languagetool}/bin/languagetool-http-server --port 8081 --allow-origin '*'";
    };
  };

  # Creating a service to starting the remote clipboard listener on user login
  systemd.user.services.rcb_listener = {
    Unit = { Description = "Remote clipboard listener service"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = { ExecStart = "${hm_binlocal}/rcb_listener.py --port 9543"; };
  };
}
