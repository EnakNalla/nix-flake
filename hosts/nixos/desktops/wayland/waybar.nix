{
  vars,
  pkgs,
  ...
}: {
  home-manager.users.${vars.user}.programs.waybar = {
    enable = true;

    settings = {
      main = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        modules-left = [
          "hyprland/workspaces"
          "wlr/taskbar"
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          "pulseaudio"
          "cpu"
          "memory"
          "battery"
          "custom/startmenu"
          "tray"
          "clock"
        ];

        "hyprland/taskbar" = {
          "on-click" = "activate";
          "on-click-middle" = "close";
          "ignore-list" = ["foot"];
        };

        "hyprland/workspaces" = {
          "on-click" = "activate";
          "on-scroll-up" = "hyprctl dispatch workspace e-1";
          "on-scroll-down" = "hyprctl dispatch workspace e+1";
        };

        "hyprland/window" = {
          "max-length" = 48;
        };

        clock = {
          interval = 1;
          format = "{:%H:%M:%S}";
          "tooltip-format" = "{:%d-%m-%Y}";
        };

        tray = {
          spacing = 4;
        };

        backlight = {
          device = "intel_backlight";
          format = "{percent}% <span font='11'>{icon}</span>";
          format-icons = [
            ""
            "󰖙"
          ];
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl --class backlight set 5%-";
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl --class backlight set 5%+";
        };

        battery = {
          interval = 1;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
          max-length = 25;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-bluetooth-muted = "x {volume}%";
          format-muted = "x {volume}%";
          format-icons = [
            " "
            " "
            " "
          ];
          tooltip-format = "{desc}, {volume}%";
          scroll-step = 5;
          on-click = "${pkgs.pamixer}/bin/pamixer -t";
          on-click-right = "${pkgs.pamixer}/bin/pamixer --default-source -t";
          on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        cpu = {
          interval = 5;
          format = "  {usage:2}%";
          tooltip = true;
        };

        memory = {
          interval = 5;
          format = "  {}%";
          tooltip = true;
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='base00'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='base00'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='base00'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='base00'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && task-waybar";
          escape = true;
        };
      };
    };
  };
}
