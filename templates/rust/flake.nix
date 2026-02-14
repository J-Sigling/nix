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
        rustLib = nix-lib.lib.rust.${system};
      in
      {
        devShell = rustLib.mkRustShell {
          # Add your project-specific customizations here
          extraEnv = {
            # Add environment variables here
            # EXAMPLE_VAR = "value";
          };
          extraNativeBuildInputs = [
            # Add build-time tools here
            # pkgs.cmake
          ];
          extraBuildInputs = [
            # Add runtime dependencies here
            # pkgs.postgresql
          ];
          extraShellHook = ''
            # Add extra shell hook commands here
          '';
        };
      }
    );
}
