{ config, pkgs, ... }:

{
  # X11 keyboard layout
  services.xserver = {
    enable = true;
    xkb = {
      layout = "se";
      variant = "";
    };
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  #Networking applet
  programs.nm-applet.enable = true;
  
  #Bluetooth Program
  services.blueman.enable = true;
}
