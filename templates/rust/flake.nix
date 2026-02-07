{
  description = "Rust development environment with RustRover";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, nix-jetbrains-plugins }:
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
        jetbrainsPlugins = nix-jetbrains-plugins.packages.${system};
        rustroverWithPlugins = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover [
            jetbrainsPlugins.ideavim
            jetbrainsPlugins.nixidea
        ];
      in
      {
        devShell = with pkgs; mkShell rec {
          nativeBuildInputs = [
            pkg-config
          ];
          buildInputs = [
            rustToolchain
            rustroverWithPlugins
            bash
            udev
          ];
          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          shellHook = ''
            echo -e "\nStarting RustRover DevShell:\nloading..."
            rust-rover .
          '';
        };
      }
    );
}
