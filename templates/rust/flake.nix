{
  description = "Rust development environment with RustRover";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-lib.url = "github:j-sigling/nix";  # Update this to your actual GitHub username/repo
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, nix-lib }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rustLib = nix-lib.lib.rust.${system};
      in
      {
        devShell = rustLib.mkRustShell {
          # Add your project-specific customizations here
          extraEnv = {
            # Add environment variables here
            # EXAMPLE_VAR = "value";
          };
          extraNativeBuildInputs = with pkgs; [
            # Add build-time tools here
            # cmake
          ];
          extraBuildInputs = with pkgs; [
            # Add runtime dependencies here
            # postgresql
          ];
          extraShellHook = ''
            # Add extra shell hook commands here
          '';
        };
      }
    );
}
