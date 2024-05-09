# NIX Configurations for zsh. Due to the complexity of the configuration, the
# main configuration will still use the nix-less methods. Nix is just
# responsible for setting up the symbolic link in the home directory.
{ inputs, pkgs, config, ... }: {
  # Link to the major configuration path
  home.file.".zsh/".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/zsh/";
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/zsh/zshrc.zsh";

}
