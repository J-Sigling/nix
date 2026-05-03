{ nixpkgs, flake-utils }:
system:
let
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    inherit system;
  };
in
{
  # Function to create a Blender dev shell with additional packages
  mkBlenderShell = { extraBuildInputs ? [], extraNativeBuildInputs ? [], extraEnv ? {}, extraShellHook ? "" }:
    with pkgs;
    let
      allNativeBuildInputs = extraNativeBuildInputs;

      allBuildInputs = [
        blender
      ] ++ extraBuildInputs;

      trimmedExtraShellHook = lib.strings.trim extraShellHook;
    in
    mkShell (extraEnv // {
      nativeBuildInputs = allNativeBuildInputs;
      buildInputs = allBuildInputs;

      shellHook = ''
        echo "Starting Blender..."
      '' + (if trimmedExtraShellHook != "" then trimmedExtraShellHook + "\n" else "") + ''
        exec blender .
      '';
    });

  # Export useful items
  inherit pkgs;
}