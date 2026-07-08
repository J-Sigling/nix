{ nixpkgs, flake-utils }:
system:
let
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    inherit system;
  };
in
{
  # Function to create a Python dev shell with uv and ruff
  mkPythonShell = {
    pythonVersion ? pkgs.python312,
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
        pythonVersion
        uv
        ruff
      ] ++ extraBuildInputs;

      trimmedExtraShellHook = lib.strings.trim extraShellHook;
    in
    mkShell (extraEnv // {
      # Environment Variables
      buildInputs = allBuildInputs;
      nativeBuildInputs = allNativeBuildInputs;

      shellHook = ''
        echo "Python development environment activated"
        echo "Python: $(python --version)"
        echo "uv: $(uv --version)"
        echo "ruff: $(ruff --version)"
      '' + (if trimmedExtraShellHook != "" then "\n" + trimmedExtraShellHook else "");
    });

  # Export useful items
  inherit pkgs;
}
