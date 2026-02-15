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
    steam-run
  ];
}
