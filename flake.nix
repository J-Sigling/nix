{
  description = "Personal Nix configurations and flake libraries";

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
    {
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

      # Expose reusable library functions
      lib = {
        rust = import ./lib/rust.nix {
          inherit nixpkgs flake-utils rust-overlay;
        };
        # Add more libraries here:
        # python = import ./lib/python.nix { ... };
      };

      # Templates for new projects
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust project template using the rust library";
        };
        # Add more templates here:
        # python = {
        #   path = ./templates/python;
        #   description = "Python development environment";
        # };
      };
    };
}
