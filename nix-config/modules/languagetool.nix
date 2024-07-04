{ config, pkgs, ... }: {
  home.packages = [ pkgs.languagetool ];
  systemd.user.services.languagetool = {
    Unit = { Description = "Starting the languagetool server"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      ExecStart =
        "${pkgs.languagetool}/bin/languagetool-http-server --port 8081 --allow-origin '*'";
    };
  };
}
