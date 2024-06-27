{ config, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    policies = {
      BlockAboutConfig = true; # Setting about configurations to
    };
    profiles = {
      # Creating the profile and defining the start conditions. The main
      # handling of ensuring items are synced with be done via Firefox sync, as
      # bookmark will likely frequently be edited
      casual = {
        name = "casual"; # What is usually used for everyday browsing
        isDefault = true;
        id = 0;
        settings = {
          "browser.newtabpage.pinned" = [{
            title = "Youtube";
            url = "https://youtube.com";
          }];
        };
      };
      work = {
        name = "work";
        isDefault = false;
        id = 1;
      };
    };
  };

  # Creating the application entry 
  xdg.desktopEntries = {
    "firefox.work" = {
      name = "Firefox - work";
      genericName = "Web Browser";
      exec = "firefox -P work %U";
      icon = "firefox-nightly";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
    "firefox.default" = {
      name = "Firefox - default";
      genericName = "Web Browser";
      exec = "firefox -P casual %U";
      icon = "firefox";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };
}
