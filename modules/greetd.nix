{ config, pkgs, ... }:

{
  # Greetd display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -- ${pkgs.regreet}/bin/regreet";
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
      # Skip user/session selection and use the last used ones
      skip_selection = true;
    };
  };

  # Seed regreet's "last session" cache on every boot so Hyprland is always used.
  # ReGreet falls back to the user's login shell when no session and no cached
  # entry exist (it ignores /etc/greetd/environments).
  systemd.tmpfiles.settings."10-regreet-seed" = {
    "/var/lib/regreet/state.toml".W = {
      user = "greeter";
      group = "greeter";
      mode = "0644";
      argument = ''
        last_user = "siglaz"
        [user_to_last_sess]
        siglaz = "Hyprland"
      '';
    };
  };
}
