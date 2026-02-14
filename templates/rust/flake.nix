{
  description = "Rust development environment with RustRover";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
            config.allowUnfree = true;
            inherit system overlays;
        };
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" ];
        };

        # Function to create a Rust dev shell with additional packages
        mkRustShell = { extraBuildInputs ? [], extraNativeBuildInputs ? [], extraEnv ? {}, shellHook ? "" }:
          with pkgs; mkShell rec {
            nativeBuildInputs = [
              pkg-config
            ] ++ extraNativeBuildInputs;

            buildInputs = [
              rustToolchain
              bash
              udev
              openssl
            ] ++ extraBuildInputs;

            #Environment Variables
            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
            ACCOUNTS_URL = "http://localhost:3000/demo/adAccounts";
          } // extraEnv // {
            shellHook = ''
              echo -e "\nStarting RustRover DevShell:\nloading..."
              exec /home/siglaz/.local/share/JetBrains/Toolbox/scripts/rustrover .
              ${shellHook}
            '';
          };
      in
      {
        # Default devShell for this template
        devShell = mkRustShell {};

        # Export the builder function for other projects to use
        lib = {
          inherit mkRustShell;
          inherit rustToolchain;
          inherit pkgs;
        };
      }
    );
}
