{ config, pkgs, hostname, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/desktop.nix
    ../modules/users/siglaz.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = hostname;

  # Home Manager
  home-manager.useGlobalPkgs = true;
  home-manager.users.siglaz = { pkgs, config, ... }: {
    imports = [
      ../home/siglaz/common.nix
      ../home/siglaz/packages.nix
      ../home/siglaz/hyprland.nix
    ];
  };

  # System version
  system.stateVersion = "25.11";
}
