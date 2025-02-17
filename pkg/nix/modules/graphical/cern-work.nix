{ pkgs, config, ... }: {
  # Additional packages required for performing CERN related work
  home.packages = [
    pkgs.oracle-instantclient
    pkgs.dbeaver-bin
  ];
}
