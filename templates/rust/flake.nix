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
        # Default devShell using the library
        devShell = rustLib.mkRustShell {
          # Add your project-specific customizations here
          extraEnv = {
            ACCOUNTS_URL = "http://localhost:3000/demo/adAccounts";
          };
          shellHook = ''
            echo -e "\nStarting RustRover DevShell:\nloading..."
            exec /home/siglaz/.local/share/JetBrains/Toolbox/scripts/rustrover .
          '';
        };
      }
    );
}
