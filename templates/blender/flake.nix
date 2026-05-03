{
  description = "Blender development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-lib.url = "github:j-sigling/nix";
  };

  outputs = { self, nixpkgs, flake-utils, nix-lib }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        blenderLib = nix-lib.lib.blender.${system};
      in
      {
        devShells.default = blenderLib.mkBlenderShell {
          # Add your project-specific customizations here
          extraEnv = {
            # Add environment variables here
            # BLENDER_USER_SCRIPTS = "./scripts";
          };
          extraNativeBuildInputs = with pkgs; [
            # Add build-time tools here
          ];
          extraBuildInputs = with pkgs; [
            # Add runtime dependencies here
            # python3
          ];
          extraShellHook = ''
            # Add extra shell hook commands here
          '';
        };
      }
    );
}