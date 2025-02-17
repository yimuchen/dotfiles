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
      # Configurations for LPC systems
      homeConfigurations."yimuchen" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./pkg/nix/host/lpc.nix ];
        };
      # Configuration for lxplus systems
      homeConfigurations."yichen" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./pkg/nix/host/lxplus.nix ];
      };
      # Configuration for UMD clusters
      homeConfigurations."yichen@hepcms-rubin" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./pkg/nix/host/umdcms.nix ];
        };
      # Configuration for KIT cluster system
      homeConfigurations."ychen" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./pkg/nix/host/kit.nix ];
      };

      # We need to treat this as a package,
      defaultPackage.${system} = pkgs.zsh;
    };
}

