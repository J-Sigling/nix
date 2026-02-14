{
  description = "Personal Nix configurations and flake templates";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
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
