{
  description = "Personal Nix configurations and flake templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, rust-overlay }:
    let
      system = "x86_64-linux";
      rustFlake = import ./templates/rust/flake.nix;
      rustOutputs = rustFlake.outputs {
        inherit self nixpkgs flake-utils rust-overlay;
      };
    in {
    # NixOS configurations
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
      # Add more machines here:
      # another-machine = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [ ./hosts/another-machine/configuration.nix ];
      # };
    };

    # Expose template devShells directly
    devShells.${system} = {
      rust = rustOutputs.devShell.${system};
    };

    # Dev shell templates
    templates = {
      rust = {
        path = ./templates/rust;
        description = "Default rust project template";
      };
      # Add more templates here:
      # python = {
      #   path = ./templates/python;
      #   description = "Python development environment";
      # };
    };
  };
}
