{ config, pkgs, ... }:

{
  users.users.siglaz = {
    isNormalUser = true;
    description = "Jacob Sigling";
    extraGroups = [
      "networkmanager"
      "wheel"
      "tty"
      "dialout"
    ];
  };
}
