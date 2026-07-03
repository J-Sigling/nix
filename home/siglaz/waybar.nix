{ pkgs, config, ... }:

{
    programs.waybar = {
        enable = true;
        settings = {
            mainBar = {
                layer = "top";
                position = "bottom";
                modules-right = ["tray" "pulseaudio" "clock"];
                tray = {
                    spacing = 10;
                };
                pulseaudio = {
                    format = "{volume}% {icon}";
                    format-muted = "󰝟 {volume}%";
                    format-icons = {
                        default = ["" "" ""];
                    };
                    on-click = "pavucontrol";
                    on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
                    on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
                    tooltip-format = "{desc}, {volume}%";
                };
            };
        };
    };
}