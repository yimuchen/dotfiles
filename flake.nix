{
  description = "Home Manager configuration of yimuchen";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Configurations for personal systems
      homeConfigurations."ensc" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./nix-config/host/personal.nix ];
      };
      # Configurations for LPC systems
      homeConfigurations."yimuchen" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./nix-config/host/lpc.nix ];
      };
      # We need to treat this as a package,
      defaultPackage.${system} = pkgs.zsh;

      # Adding shell that is required for developement using editors, this is
      # mainly to include additional language servers and formatters that are
      # not listed for interactive use.
      devShells.${system} = {
        default = pkgs.mkShell {
          name = "Development environment for dotfiles";
          packages = [
            # Lua tools for neovim configurations
            pkgs.lua-language-server
            pkgs.stylua

            # shell tools for environment configurations
            pkgs.nodePackages.bash-language-server
            pkgs.shfmt

            # Python language tools
            pkgs.ruff-lsp
            (pkgs.python3.withPackages (ps: [ ps.pykeepass ps.argcomplete ]))
          ];
        };
        # Additional development shells
        python = (import ./devshells/python.nix pkgs);
        lua = (import ./devshells/lua.nix pkgs);
        tex = (import ./devshells/tex.nix pkgs);
      };
    };
}

