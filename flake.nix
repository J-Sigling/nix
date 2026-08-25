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
    opencode.url = "github:anomalyco/opencode/v1.18.23";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, rust-overlay, opencode }:
    let
      rustLib = import ./lib/rust.nix {
        inherit nixpkgs flake-utils rust-overlay;
      };
      blenderLib = import ./lib/blender.nix {
        inherit nixpkgs flake-utils;
      };
      pythonLib = import ./lib/python.nix {
        inherit nixpkgs flake-utils;
      };
      # Applies an overlay so home-manager's `pkgs.opencode` resolves to the
      # flake-provided (latest) version instead of the stale nixpkgs one.
      applyOverlays = overlay: { ... }: {
        nixpkgs.overlays = [ overlay ];
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
            (applyOverlays opencode.overlays.default)
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
            (applyOverlays opencode.overlays.default)
          ];
        };
      };

      # Expose reusable library functions
      lib = flake-utils.lib.eachDefaultSystem (system: {
        rust = rustLib system;
        blender = blenderLib system;
        python = pythonLib system;
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
        python = {
          path = ./templates/python;
          description = "Python project template with uv and ruff";
        };
        dioxus = {
          path = ./templates/skills/dioxus;
          description = "Dioxus 0.7 OpenCode skill";
        };
      };

    } // flake-utils.lib.eachDefaultSystem (system: {
      # Development shells
      devShells.default = (rustLib system).mkRustShell { };
    });
}
