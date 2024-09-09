{ pkgs, ... }:
(pkgs.mkShell {
  name = "Environment for tex writing";
  packages = [
    pkgs.texlive.combined.scheme-full # Load everything
    pkgs.biber
    pkgs.texlab
  ];
})

