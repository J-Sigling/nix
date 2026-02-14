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
  mkRustShell = { extraBuildInputs ? [], extraNativeBuildInputs ? [], extraEnv ? {}, extraShellHook ? "" }:
    with pkgs;
    let
      allNativeBuildInputs = [
        pkg-config
      ] ++ extraNativeBuildInputs;

      allBuildInputs = [
        rustToolchain
        bash
        udev
        openssl
      ] ++ extraBuildInputs;
    in
    mkShell (extraEnv // {
      #Environment Variables
      LD_LIBRARY_PATH = lib.makeLibraryPath allBuildInputs;
      nativeBuildInputs = allNativeBuildInputs;
      buildInputs = allBuildInputs;

      shellHook = ''
        echo -e "\nStarting RustRover DevShell:\nloading..."
        exec /home/siglaz/.local/share/JetBrains/Toolbox/scripts/rustrover .
      '' + extraShellHook;
    });

  # Export useful items
  inherit rustToolchain;
  inherit pkgs;
}
