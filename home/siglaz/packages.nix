{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brave
    discord
    spotify
    libreoffice-fresh
    hunspell
    hunspellDicts.uk_UA
    jetbrains-toolbox
    networkmanagerapplet
    pavucontrol
    claude-code
    opencode
    unrar
    unzip
    cameractrls-gtk4
  ];
}
