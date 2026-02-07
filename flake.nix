{
  description = "Personal Nix configurations and flake templates";

  outputs = { self }: {
    templates = rec {
      rust = {
        path = ./templates/rust;
        description = "Default rust project template";
      };
    };
  };
}