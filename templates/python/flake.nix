{
  description = "Python development environment with uv and ruff";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-lib.url = "github:j-sigling/nix";  # Update this to your actual GitHub username/repo
  };

  outputs = { self, nixpkgs, flake-utils, nix-lib }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonLib = nix-lib.lib.python.${system};
      in
      {
        devShell = pythonLib.mkPythonShell {
          # Add your project-specific customizations here
          # pythonVersion = pkgs.python311;  # Override Python version if needed
          extraEnv = {
            # Add environment variables here
            # EXAMPLE_VAR = "value";
          };
          extraNativeBuildInputs = with pkgs; [
            # Add build-time tools here
            # gcc
          ];
          extraBuildInputs = with pkgs; [
            # Add runtime dependencies here
            # postgresql
          ];
          extraShellHook = ''
            # Add extra shell hook commands here
            # uv venv --python ${pkgs.python312}/bin/python
          '';
        };
      }
    );
}
