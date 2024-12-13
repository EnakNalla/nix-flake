{
  config,
  lib,
  inputs,
  pkgs,
  host,
  vars,
  ...
}: let
  colours = import ../../utils/colours.nix;

  hyprland = inputs.hyprland;
in
  with lib;
  with host; {
    environment = let
      exec = "exec dbus-launch hyprland";
    in {
      loginShellInit = ''
        if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
          ${exec}
        fi
      '';

      variables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XCURSOR_SIZE = 24;
      };
      sessionVariables = {
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        GDK_BACKEND = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
        MOZ_ENABLE_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        NIXOS_OZONE_WL = "1";
      };
      systemPackages = with pkgs; [
        hyprcursor # Cursor theming
        hyprpaper # wallpaper manager
        wl-clipboard
        wlr-randr # screen management
      ];
    };

    programs.hyprland = {
      enable = true;
      package = hyprland.packages.${pkgs.system}.hyprland;
    };

    security.pam.services.hyprlock = {
      text = "auth include login";
      fprintAuth =
        if hostName == "laptop"
        then true
        else false;
      enableGnomeKeyring = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.programs.hyprland.package}/bin/Hyprland";
          user = vars.user;
        };
      };
      vt = 7;
    };

    # clamshell mode
    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=yes
    '';

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    home-manager.users.${vars.user} = let
      lockScript = pkgs.writeShellScript "lock-script" ''
        action=$1
        ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
        if [ $? == 1 ]; then
          if [ "$action" == "lock" ]; then
            ${pkgs.hyprlock}/bin/hyprlock
          elif [ "$action" == "suspend" ]; then
            ${pkgs.systemd}/bin/systemctl suspend
          fi
        fi
      '';

      clamshell = pkgs.writeShellScript "clamshell-script" ''
        if [[ $(hyprctl monitors 2>/dev/null | rg "\sDP-[0-9]+") ]]; then
          if [[ $1 == "open" ]]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,preferred,auto,auto"
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,disable"
          fi
        else
          if [[ $1 != "open" ]]; then
            ${pkgs.hyprlock}/bin/hyprlock
          fi
        fi
      '';
    in {
      imports = [
        hyprland.homeManagerModules.default
      ];

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            no_fade_in = false;
            disable_loading_bar = false;
            grace = 1;
          };
          background = [
            {
              monitor = "";
              path = "$HOME/.config/wall.png";
              color = "rgba(25, 20, 20, 1.0)";
              blur_passes = 1;
              blur_size = 0;
              brightness = 0.2;
            }
          ];
          input-field = [
            {
              monitor = "";
              size = "250, 60";
              outline_thickness = 2;
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              outer_color = "rgba(0, 0, 0, 0)";
              inner_color = "rgba(0, 0, 0, 0.5)";
              font_color = "rgb(200, 200, 200)";
              fade_on_empty = false;
              placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
              hide_input = false;
              position = "0, -120";
              halign = "center";
              valign = "center";
            }
          ];
          label = [
            {
              monitor = "";
              text = "$TIME";
              font_size = 120;
              position = "0, 80";
              valign = "center";
              halign = "center";
            }
          ];
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
            after_sleep_cmd = "${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on";
            ignore_dbus_inhibit = true;
            lock_cmd = "pidof ${pkgs.hyprlock}/bin/hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "${lockScript.outPath} lock";
            }
            {
              timeout = 1800;
              on-timeout = "${lockScript.outPath} suspend";
            }
          ];
        };
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = true;
          splash = false;
          preload = "$HOME/.config/wall.png";
          wallpaper = ",$HOME/.config/wall.png";
        };
      };

      wayland.windowManager.hyprland = with colours.hypr; {
        enable = true;
        package = hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true;

        settings = {
          monitor = [
            "eDP-1,preferred,auto,auto"
            "DP-3,preferred,auto,auto"
          ];
          workspace = [];
          general = {
            border_size = 2;
            no_border_on_floating = false;
            "col.active_border" = "rgb(${active})";
            "col.inactive_border" = "rgb(${inactive})";
            resize_on_border = false;
            allow_tearing = false;
            layout = "dwindle";
          };
          decoration = {
            rounding = 10;
            "col.shadow" = "rgba(1E202966)";
            drop_shadow = "yes";
            shadow_range = 60;
            shadow_offset = "1 2";
            shadow_render_power = 3;
            shadow_scale = 0.97;
            active_opacity = 1;
            inactive_opacity = 0.8;
          };
          animations = {
            enabled = true;
            bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };
          input = {
            kb_layout = "gb";
            kb_options = "caps:ctrl_modifier";
            accel_profile = "flat";
            touchpad =
              if hostName == "laptop"
              then {
                natural_scroll = true;
                scroll_factor = 0.2;
                middle_button_emulation = true;
                tap-to-click = true;
              }
              else {};
          };
          cursor = {
            no_hardware_cursors = true;
          };
          dwindle = {
            pseudotile = false;
            force_split = 2;
            preserve_split = true;
          };
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            mouse_move_enables_dpms = true;
            mouse_move_focuses_monitor = true;
            key_press_enables_dpms = true;
            background_color = "0x111111";
          };
          windowrulev2 = [
            "float,title:^(Volume Control)$"
            "suppressevent maximize, class:.*"
          ];
          exec-once = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "${pkgs.hyprlock}/bin/hyprlock"
            "ln -s $XDG_RUNTIME_DIR/hypr /tmp/hypr"
            "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
            "${pkgs.waybar}/bin/waybar -c $HOME/.config/waybar/config"
          ];
          bind = [
            "SUPER,RETURN,exec,${pkgs.${vars.terminal}}/bin/${vars.terminal}"
            "SUPERSHIFT,RETURN,exec,${pkgs.firefox}/bin/firefox"
            "SUPER,E,exec,${pkgs.dolphin}/bin/dolphin"
            "SUPER,SPACE,exec,${pkgs.wofi}/bin/wofi --show drun"

            "SUPER,Q,killactive,"
            "SUPERSHIFT, Q, exit,"

            "SUPER,T,togglefloating,"
            "SUPER,F,fullscreen,1"

            "SUPER,H,movefocus,l"
            "SUPER,J,movefocus,d"
            "SUPER,K,movefocus,u"
            "SUPER,L,movefocus,r"

            "SUPERSHIFT,H,movewindow,l"
            "SUPERSHIFT,J,movewindow,d"
            "SUPERSHIFT,K,movewindow,u"
            "SUPERSHIFT,L,movewindow,r"

            "SUPER,right,resizeactive, 30 0"
            "SUPER,left,resizeactive, -30 0"
            "SUPER,down,resizeactive, 0 30"
            "SUPER,up,resizeactive, 0 -30"

            "SUPER,1,workspace,1"
            "SUPER,2,workspace,2"
            "SUPER,3,workspace,3"
            "SUPER,4,workspace,4"
            "SUPER,5,workspace,5"

            "SUPERSHIFT,1,movetoworkspace,1"
            "SUPERSHIFT,2,movetoworkspace,2"
            "SUPERSHIFT,3,movetoworkspace,3"
            "SUPERSHIFT,4,movetoworkspace,4"
            "SUPERSHIFT,5,movetoworkspace,5"

            "SUPER,S,exec,${pkgs.systemd}/bin/systemctl suspend"
            "SUPERCTRL,L,exec,${pkgs.hyprlock}/bin/hyprlock"
          ];
          bindel = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86MonBrightnessUp, exec, brightnessctl --class backlight set 5%+"
            ", XF86MonBrightnessDown, exec, brightnessctl --class backlight set 5%-"
          ];
          bindl = [
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPause, exec, playerctl pause"
            ", XF86AudioStop, exec, playerctl stop"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
            ",switch:off:Lid Switch,exec,${clamshell.outPath} open"
            ",switch:on:Lid Switch,exec,${clamshell.outPath} close"
          ];
        };
      };
    };
  }
