{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wofi  # Wayland app launcher
    waybar  # Status bar
    mako  # Notification daemon
    grim  # Screenshot tool
    slurp  # Screen area selector
    swaylock-effects  # Lock screen
    wl-clipboard  # Clipboard utilities
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
        "nm-applet --indicator"
        "waybar"
        "mako"
      ];

      # Variables
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$browser" = "brave";
      "$launcher" = "wofi --show drun";


      # Keybindings
      bind = [
        # Application shortcuts
        "$mainMod, K, exec, $terminal"
        "$mainMod, B, exec, $browser"
        "$mainMod, S, exec, spotify"
        "$mainMod, D, exec, $launcher"

        # Screenshot shortcuts
        ", PRINT, exec, grim - | wl-copy"  # Full screenshot to clipboard
        "$mainMod, PRINT, exec, grim -g \"$(slurp)\" - | wl-copy"  # Area screenshot
        "$mainMod SHIFT, PRINT, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"  # Save full screenshot

        # Lock screen
        "$mainMod, L, exec, swaylock -f"

        # Window actions
        "$mainMod, C, killactive"
        "$mainMod, E, exit"
        "$mainMod, O, exec, hyprctl dispatch exit"
        "$mainMod, Q, togglefloating"
        "$mainMod, F, fullscreen, 0"
        "$mainMod, P, pseudo"
        "$mainMod, J, togglesplit"


        # Window focus navigation (arrow keys)
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Move windows (arrow keys)
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"

        # Enter workspace view mode (mainMod + V)
        "$mainMod, V, submap, view_workspace"

        # Enter workspace move mode (mainMod + M)
        "$mainMod, M, submap, move_workspace"

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
        border_size = 3;
        "col.active_border" = "rgba(ff0000ee) rgba(880000ee) 45deg";  # Red gradient
        "col.inactive_border" = "rgba(1a1a1aaa)";  # Dark gray/black
        layout = "dwindle";
        allow_tearing = false;
      };

      # Decoration
      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          xray = false;
          ignore_opacity = false;
        };

        # Shadow configuration
        drop_shadow = true;
        shadow_range = 30;
        shadow_render_power = 3;
        shadow_offset = "0 0";
        "col.shadow" = "rgba(ff000055)";  # Red shadow for active windows
        "col.shadow_inactive" = "rgba(00000055)";

        # Opacity
        active_opacity = 1.0;
        inactive_opacity = 0.92;
        fullscreen_opacity = 1.0;

        # Dimming
        dim_inactive = true;
        dim_strength = 0.15;
      };

      # Animations
      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
          "linear, 0.0, 0.0, 1.0, 1.0"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 10, default"
          "borderangle, 1, 100, linear, loop"  # Smooth rotating border
          "fade, 1, 8, default"
          "workspaces, 1, 5, wind, slidevert"
          "specialWorkspace, 1, 6, default, slidefadevert"
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
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        vrr = 1;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
      };

      # Window rules for better aesthetics
      windowrulev2 = [
        # Float specific windows
        "float, class:^(pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"

        # Opacity rules for terminal
        "opacity 0.9 0.9, class:^(kitty)$"
        "opacity 0.9 0.9, class:^(Alacritty)$"

        # Workspace assignments
        "workspace 1, class:^(Code)$"
        "workspace 1, class:^(jetbrains-*)$"
        "workspace 3, class:^(brave-browser)$"
        "workspace 3, class:^(firefox)$"
        "workspace 4, class:^(Spotify)$"

        # Remove shadows from specific windows
        "noshadow, floating:0"
      ];
    };

    # Submap configurations (must use extraConfig)
    extraConfig = ''
      # Submap for viewing workspaces (SUPER + V, then number)
      submap = view_workspace
      bind = , 1, workspace, 1
      bind = , 1, submap, reset
      bind = , 2, workspace, 2
      bind = , 2, submap, reset
      bind = , 3, workspace, 3
      bind = , 3, submap, reset
      bind = , 4, workspace, 4
      bind = , 4, submap, reset
      bind = , 5, workspace, 5
      bind = , 5, submap, reset
      bind = , 6, workspace, 6
      bind = , 6, submap, reset
      bind = , 7, workspace, 7
      bind = , 7, submap, reset
      bind = , 8, workspace, 8
      bind = , 8, submap, reset
      bind = , 9, workspace, 9
      bind = , 9, submap, reset
      bind = , 0, workspace, 10
      bind = , 0, submap, reset
      bind = , KP_End, workspace, 1
      bind = , KP_End, submap, reset
      bind = , KP_Down, workspace, 2
      bind = , KP_Down, submap, reset
      bind = , KP_Next, workspace, 3
      bind = , KP_Next, submap, reset
      bind = , KP_Left, workspace, 4
      bind = , KP_Left, submap, reset
      bind = , KP_Begin, workspace, 5
      bind = , KP_Begin, submap, reset
      bind = , KP_Right, workspace, 6
      bind = , KP_Right, submap, reset
      bind = , KP_Home, workspace, 7
      bind = , KP_Home, submap, reset
      bind = , KP_Up, workspace, 8
      bind = , KP_Up, submap, reset
      bind = , KP_Prior, workspace, 9
      bind = , KP_Prior, submap, reset
      bind = , KP_Insert, workspace, 10
      bind = , KP_Insert, submap, reset
      bind = , escape, submap, reset
      submap = reset

      # Submap for moving windows to workspaces (SUPER + M, then number)
      submap = move_workspace
      bind = , 1, movetoworkspace, 1
      bind = , 1, submap, reset
      bind = , 2, movetoworkspace, 2
      bind = , 2, submap, reset
      bind = , 3, movetoworkspace, 3
      bind = , 3, submap, reset
      bind = , 4, movetoworkspace, 4
      bind = , 4, submap, reset
      bind = , 5, movetoworkspace, 5
      bind = , 5, submap, reset
      bind = , 6, movetoworkspace, 6
      bind = , 6, submap, reset
      bind = , 7, movetoworkspace, 7
      bind = , 7, submap, reset
      bind = , 8, movetoworkspace, 8
      bind = , 8, submap, reset
      bind = , 9, movetoworkspace, 9
      bind = , 9, submap, reset
      bind = , 0, movetoworkspace, 10
      bind = , 0, submap, reset
      bind = , KP_End, movetoworkspace, 1
      bind = , KP_End, submap, reset
      bind = , KP_Down, movetoworkspace, 2
      bind = , KP_Down, submap, reset
      bind = , KP_Next, movetoworkspace, 3
      bind = , KP_Next, submap, reset
      bind = , KP_Left, movetoworkspace, 4
      bind = , KP_Left, submap, reset
      bind = , KP_Begin, movetoworkspace, 5
      bind = , KP_Begin, submap, reset
      bind = , KP_Right, movetoworkspace, 6
      bind = , KP_Right, submap, reset
      bind = , KP_Home, movetoworkspace, 7
      bind = , KP_Home, submap, reset
      bind = , KP_Up, movetoworkspace, 8
      bind = , KP_Up, submap, reset
      bind = , KP_Prior, movetoworkspace, 9
      bind = , KP_Prior, submap, reset
      bind = , KP_Insert, movetoworkspace, 10
      bind = , KP_Insert, submap, reset
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
