{ pkgs, config, ... }:

{
    programs.waybar = {
        enable = true;
        settings = {
            mainBar = {
                layer = "top";
                position = "top";
                modules-right = ["tray" "clock"];
                tray = {
                    spacing = 10;
                };
            };
        };
    };
}