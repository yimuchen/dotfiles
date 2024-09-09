{ pkgs, ... }:
(pkgs.mkShell {
  name = "Development environment for lua packages";
  packages = [ pkgs.lua-language-server pkgs.stylua ];
})

