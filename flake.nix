{
  description = "Personal Nix configurations and flake libraries";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, rust-overlay }:
    let
      rustLib = import ./lib/rust.nix {
        inherit nixpkgs flake-utils rust-overlay;
      };
      blenderLib = import ./lib/blender.nix {
        inherit nixpkgs flake-utils;
      };
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { hostname = "nixos"; };
          modules = [
            ./hosts/nixos/hardware-configuration.nix
            ./hosts/configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };

        snake = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { hostname = "snake"; };
          modules = [
            ./hosts/snake/hardware-configuration.nix
            ./hosts/configuration.nix
            ./hosts/snake/host.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # Expose reusable library functions
      lib = flake-utils.lib.eachDefaultSystem (system: {
        rust = rustLib system;
        blender = blenderLib system;
      });

      # Templates for new projects
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust project template using the rust library";
        };
        blender = {
          path = ./templates/blender;
          description = "Blender development environment";
        };
      };

    } // flake-utils.lib.eachDefaultSystem (system: {
      # Development shells
      devShells.default = (rustLib system).mkRustShell { };
    });
}
