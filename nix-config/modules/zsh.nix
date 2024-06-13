# NIX Configurations for zsh. Due to the complexity of the configuration, the
# main configuration will still use the nix-less methods. Nix is just
# responsible for setting up the symbolic link in the home directory.
{ config, ... }: {
  # Additional packages that is required to use the various configuration.
  # Because zsh should be considered a system package, do *not* put zsh here

  # Link to the major configuration path
  home.file.".zsh".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/zsh";
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/zsh/zshrc.zsh";
  home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/home-manager/zsh/p10k.zsh";
}
