{ pkg, config, ... }: {
  # Ignore system level configurations
  programs.git.extraConfig = {
    core = { sshComm = "ssh -F ~/.ssh/config"; };
  };
}
