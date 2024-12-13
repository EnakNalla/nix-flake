{
  vars,
  pkgs,
  ...
}: let
  colours = import ../../utils/colours.nix;
in {
  home-manager.users.${vars.user} = {
    home = {
      packages = with pkgs; [
        wofi
      ];
    };

    home.file = with colours.hex; {
      ".config/wofi/style.css" = {
        text = ''
          window {
          margin: 0px;
          border: 1px solid ${purple};
          background-color: ${bg};
          border-radius: 10px;
          }

          #input {
          margin: 5px;
          border: none;
          color: ${fg};
          background-color: ${currentLine};
          }

          #inner-box {
          margin: 5px;
          border: none;
          background-color: ${bg};
          }

          #outer-box {
          margin: 5px;
          border: none;
          background-color: ${bg};
          }

          #scroll {
          margin: 0px;
          border: none;
          }

          #text {
          margin: 5px;
          border: none;
          color: ${fg};
          }

          #entry.activatable #text {
          color: ${bg};
          }

          #entry > * {
          color: ${fg};
          }

          #entry:selected {
          background-color: ${currentLine};
          }

          #entry:selected #text {
          font-weight: bold;
          }
        '';
      };

      ".config/wofi/power.sh" = {
        executable = true;
        text = ''
          #!/bin/sh

          entries="󰍃 Logout\n󰒲 Suspend\n Reboot\n⏻ Shutdown"

          selected=$(echo -e $entries|wofi --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

          case $selected in
            logout)
              exec hyprctl dispatch exit;;
            suspend)
              exec systemctl suspend;;
            reboot)
              exec systemctl reboot;;
            shutdown)
              exec systemctl poweroff -i;;
          esac
        '';
      };
    };
  };
}
