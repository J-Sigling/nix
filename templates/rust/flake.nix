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
      in
      {
        devShell = with pkgs; mkShell rec {
          nativeBuildInputs = [
            pkg-config
          ];
          buildInputs = [
            rustToolchain
            bash
            udev
            openssl
          ];
          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          shellHook = ''
            echo -e "\nStarting RustRover DevShell:\nloading..."
            rust-rover
          '';
        };
      }
    );
}
