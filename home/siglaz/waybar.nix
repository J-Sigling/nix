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
                    tooltip-format = "{desc}, {volume}%";
                };
            };
        };
    };
}