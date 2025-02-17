# Windows-like panel at the bottom
{ }:
let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  clock_common = {
    calendar.firstDayOfWeek = "sunday";
    time.format = "24h";
    time.showSeconds = "onlyInTooltip";
    date.format = "isoDate";
    date.position = "belowTime";
    timeZone.format = "city";
    timeZone.alwaysShow = true;
  };
in {
  location = "bottom";
  height = 50;
  hiding = "autohide";
  floating = true;
  widgets = [
    { # Generic launcher
      kickoff = {
        sortAlphabetically = true;
        icon = "nix-snowflake-white";
      };
    }
    {
      iconTasks = {
        launchers = [
          "applications:systemsettings.desktop"
          "applications:com.mitchellh.ghostty.desktop"
          "applications:org.kde.dolphin.desktop"
          "applications:firefox.default.desktop"
          "applications:firefox.work.desktop"
          "applications:thunderbird.desktop"
          "applications:startcenter.desktop" # Libreoffice
          "applications:bitwarden.desktop"
          "applications:virt-manager.desktop"
          "applications:org.kicad.kicad.desktop"
          "applications:org.musescore.MuseScore.desktop"
        ];
      };
    }
    "org.kde.plasma.marginsseparator"
    {
      systemTray.items = {
        shown = [ # Forcing certain items to always be shown
          "org.kde.plasma.battery"
          "org.kde.plasma.networkmanagement"
          "org.kde.plasma.bluetooth"
          "org.kde.plasma.volume"
          "org.kde.plasma.manage-inputmethod"
          "org.kde.kdeconnect"
        ];
        hidden = [
          "org.kde.plasma.clipboard"
          "org.kde.plasma.keyboardlayout"
          "org.kde.plasma.keyboardindicator"
          "org.kde.kscreen"
        ];
      };
    }

    # My many clocks...
    {
      digitalClock = (lib.recursiveUpdate clock_common {
        timeZone.selected = [ "Europe/Berlin" ];
      });
    }
    {
      digitalClock = (lib.recursiveUpdate clock_common {
        timeZone.selected = [ "Asia/Taipei" ];
      });
    }
    {
      digitalClock = (lib.recursiveUpdate clock_common {
        timeZone.selected = [ "America/Chicago" ];
      });
    }
  ];
}

