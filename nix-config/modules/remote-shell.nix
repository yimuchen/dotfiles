{ pkgs, config, ... }:
let makeln = config.lib.file.mkOutOfStoreSymlink;
in {
  # Miscellaneous command line packages with no additional/minimal configurations.

  # For handling certificate generation
  home.packages = [ pkgs.cacert ];

  # Using NH nix helper to have a nicer update output
  programs.nh = {
    enable = true;
    # clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
  };

  # Re-linking the zsh path to a common position so that other programs that
  # require the full shell path can use it (tmux/neovim)
  home.files.".local/share/zsh" = makeln "${pkgs.zsh}/bin/zsh";
}
