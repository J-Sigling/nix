{ nixpkgs, flake-utils, rust-overlay }:
system:
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
    } // extraEnv // {
      shellHook = shellHook;
    };

  # Export useful items
  inherit rustToolchain;
  inherit pkgs;
}
