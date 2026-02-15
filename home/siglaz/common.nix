{ pkgs, config, ... }:

{
  home.stateVersion = "25.05";

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/JetBrains/Toolbox/scripts"
  ];
}
