{ pkgs, config, ... }:

{
  home.stateVersion = "25.11";

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/JetBrains/Toolbox/scripts"
  ];
}
