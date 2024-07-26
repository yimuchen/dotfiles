{ pkgs, config, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim # vim binning
      ms-python.python # For python
      ms-toolsai.jupyter # To render context rich notebook files
    ];
  };
}
