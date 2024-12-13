{
  pkgs,
  vars,
  host,
  ...
}: let
  colours = import ../../utils/colours.nix;

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
    "tray"
    "clock"
  ];
in
  with host; {
    environment.systemPackages = with pkgs; [
      waybar
    ];

    home-manager.users.${vars.user} = with colours.hex; {
      programs.waybar = {
        enable = true;
        package = pkgs.waybar;

        style = ''
          * {
              border: none;
              border-radius: 0;
              font-family: JetbrainsMono Nerd Font;
              font-size: 11pt;
              min-height: 0;
          }
          window#waybar {
              opacity: 0.9;
              background: ${bg};
              color: @foreground;
              border-bottom: 2px solid ${currentLine};
          }
          #workspaces button {
              padding: 0 10px;
              background: ${currentLine};
              color: ${fg};
          }
          #workspaces button:hover {
              box-shadow: inherit;
              text-shadow: inherit;
              background-image: linear-gradient(0deg, ${comment}, @background-darker);
          }
          #workspaces button.active {
              background-image: linear-gradient(0deg, ${purple}, ${comment});
          }
          #workspaces button.urgent {
              background-image: linear-gradient(0deg, ${red}, @background-darker);
          }
          #taskbar button.active {
              background-image: linear-gradient(0deg, ${comment}, @background-darker);
          }
          #clock {
              padding: 0 4px;
              background: ${currentLine};
          }

          #cpu {
            padding: 0 4px;
          }

          #memory {
            padding: 0 4px;
          }

          #battery {
            padding: 0 4px;
          }
        '';

        settings = {
          main = {
            layer = "top";
            position = "top";
            height = 24;
            spacing = 4;

            modules-left = modules-left;
            modules-center = modules-center;
            modules-right = modules-right;

            "hyprland/taskbar" = {
              "on-click" = "activate";
              "on-click-middle" = "close";
              "ignore-list" = [
                "foot"
              ];
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
              format-icons = ["" "󰖙"];
              on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl --class backlight set 5%-";
              on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl --class backlight set 5%+";
            };

            battery = {
              interval = 1;
              states = {
                warning = 30;
                critical = 15;
              };
              format = "<span font='11'>{icon}</span> {capacity}% ";
              format-charging = "<span font='11'></span> {capacity}% ";
              format-icons = ["" "" "" "" ""];
              max-length = 25;
            };

            pulseaudio = {
              format = "<span font='13'>{icon}</span> {volume}% ";
              format-bluetooth = "<span font='13'>{icon}</span> {volume}% ";
              format-bluetooth-muted = "<span font='13'>x</span> {volume}% ";
              format-muted = "<span font='13'>x</span> {volume}% ";
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
              interval = 1;
              format = "  {icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
              format-icons = [
                "<span color='${green}'>▁</span>"
                "<span color='${cyan}'>▂</span>"
                "<span color='${fg}'>▃</span>"
                "<span color='${fg}'>▄</span>"
                "<span color='${yellow}'>▅</span>"
                "<span color='${yellow}'>▆</span>"
                "<span color='${orange}'>▇</span>"
                "<span color='${red}'>█</span>"
              ];
            };

            memory = {
              interval = 30;
              format = "  {used:0.1f}G/{total:0.1f}G";
            };
          };
        };
      };
    };
  }
