{ pkgs, config, ... }:

{
    programs.waybar = {
        enable = true;
        systemd.enable = true;
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
                    on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
                    on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
                    tooltip-format = "{desc}, {volume}%";
                };
            };
        };
    };
}