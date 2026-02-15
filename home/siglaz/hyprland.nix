{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wofi  # Wayland app launcher
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["~/Pictures/nixoswallpaper.png"];
      wallpaper = ["eDP-1,~/Pictures/nixoswallpaper.png"];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration
      monitor = [
        ",preferred,auto,1"  # Auto-detect all monitors
      ];

      # Input configuration
      input = {
        kb_layout = "us,se";
        kb_variant = "";
        kb_model = "";
        kb_options = "grp:alt_space_toggle";
        kb_rules = "";
      };

      # XWayland settings
      xwayland = {
        force_zero_scaling = true;
      };

      # Autostart
      exec-once = [
        "hyprpaper"
      ];

      # Variables
      "$mainMod" = "ALT";
      "$terminal" = "kitty";
      "$browser" = "brave";
      "$launcher" = "wofi --show drun";

      # JetBrains window rules - fix focus stealing and empty windows
      windowrulev2 = [
        # Fix focus-stealing popups
        "stayfocused, class:^jetbrains-.*, floating:1, title:^(?!win\\d+$).*$"
        # Ignore empty utility windows
        "nofocus, class:^jetbrains-.*, floating:1, title:^win\\d+$"
        # Prevent initial focus on empty windows
        "noinitialfocus, class:^jetbrains-.*, floating:1, title:^$"
      ];

      # Keybindings
      bind = [
        # Application shortcuts
        "$mainMod, Q, exec, $terminal"
        "$mainMod, B, exec, $browser"
        "$mainMod, S, exec, Spotify"
        "$mainMod, D, exec, $launcher"

        # Window actions
        "$mainMod, C, killactive"
        "$mainMod, M, exit"
        "$mainMod, O, exec, hyprctl dispatch exit"
        "$mainMod, V, togglefloating"
        "$mainMod, F, fullscreen, 0"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"


        # Window focus navigation (arrow keys)
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Window focus navigation (vim keys)
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Move windows (arrow keys)
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Cycle through windows
        "$mainMod, TAB, cyclenext"
        "$mainMod SHIFT, TAB, cyclenext, prev"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"    # Left click drag to move
        "$mainMod, mouse:273, resizewindow"  # Right click drag to resize
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # Animations
      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Misc settings
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };
    };
  };
}
