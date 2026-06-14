{ config, pkgs, ... }:

{
  # Greetd display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  # Regreet configuration
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = "/etc/greetd/background.png";
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
      };
      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };
  };

  # Environment settings for Hyprland
  environment.etc."greetd/environments".text = ''
    Hyprland
  '';
}