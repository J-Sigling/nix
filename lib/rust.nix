{ nixpkgs, flake-utils, rust-overlay }:
system:
let
  overlays = [ (import rust-overlay) ];
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    inherit system overlays;
  };
  rustToolchain = pkgs.rust-bin.nightly.latest.default.override {
    extensions = [ "rust-src" ];
    targets = [ "riscv32imac-unknown-none-elf" ];
  };
in
{
  # Function to create a Rust dev shell with additional packages
  mkRustShell = {
    ide ? "rustrover",
    extraBuildInputs ? [],
    extraNativeBuildInputs ? [],
    extraEnv ? {},
    extraShellHook ? ""
  }:
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

      trimmedExtraShellHook = lib.strings.trim extraShellHook;

      # Available IDEs that the shell hook can launch
      ides = {
        rustrover = {
          name = "RustRover";
          script = "/home/siglaz/.local/share/JetBrains/Toolbox/scripts/rustrover";
        };
        pycharm = {
          name = "PyCharm";
          script = "/home/siglaz/.local/share/JetBrains/Toolbox/scripts/pycharm";
        };
        air = {
          name = "Air";
          script = "/home/siglaz/.local/share/JetBrains/Toolbox/scripts/air";
        };
      };
      selectedIde = ides.${ide} or (throw "Unknown ide '${ide}', expected one of: ${lib.concatStringsSep ", " (builtins.attrNames ides)}");
    in
    mkShell (extraEnv // {
      #Environment Variables
      LD_LIBRARY_PATH = lib.makeLibraryPath allBuildInputs;
      nativeBuildInputs = allNativeBuildInputs;
      buildInputs = allBuildInputs;

      shellHook = ''
        echo -e "\nStarting ${selectedIde.name} DevShell:\nloading..."
        exec bash ${selectedIde.script} "$PWD" &
      '' + (if trimmedExtraShellHook != "" then "\n" + trimmedExtraShellHook else "");
    });

  # Export useful items
  inherit rustToolchain;
  inherit pkgs;
}
