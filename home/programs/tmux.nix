{
  pkgs,
  config,
  ...
}:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;

    prefix = "C-Space";

    keyMode = "vi";

    terminal = "xterm-256color";

    baseIndex = 1;

    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      {
        plugin = tmux-nova;
        extraConfig = ''
          set -g status-left ""
          set -g @nova-segments-0-left ""

          set -g @nova-nerdfonts true
          set -g @nova-nerdfonts-left 
          set -g @nova-nerdfonts-right 

          set -g @nova-pane "#I#{?pane_in_mode,  #{pane_mode},}  #W"

          set -g status-bg "#${config.lib.stylix.colors.base00}"

          ### COLORS ###
          seg_a="#${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base05}"
          seg_b="#${config.lib.stylix.colors.base02} #${config.lib.stylix.colors.base05}"

          inactive_bg="#${config.lib.stylix.colors.base00}"
          inactive_fg="#${config.lib.stylix.colors.base05}"
          active_bg="#${config.lib.stylix.colors.base0D}"
          active_fg="#${config.lib.stylix.colors.base00}"

          set -gw window-status-current-style bold
          set -g "@nova-status-style-bg" "$inactive_bg"
          set -g "@nova-status-style-fg" "$inactive_fg"
          set -g "@nova-status-style-active-bg" "$active_bg"
          set -g "@nova-status-style-active-fg" "$active_fg"

          set -g "@nova-pane-active-border-style" "${config.lib.stylix.colors.base05}"
          set -g "@nova-pane-border-style" "${config.lib.stylix.colors.base01}"

          ### STATUS BAR ###
          set -g @nova-segment-prefix "#{?client_prefix,PREFIX,}"
          set -g @nova-segment-prefix-colors "$seg_b"

          set -g @nova-segment-session "#{session_name}"
          set -g @nova-segment-session-colors "$seg_a"

          set -g @nova-segment-cpu " #{cpu_percentage}"
          set -g @nova-segment-cpu-colors "$seg_b"

          set -g @nova-segment-ram " #{ram_percentage}"
          set -g @nova-segment-ram-colors "$seg_b"

          set -g @nova-segment-battery "#{battery_icon_status} #{battery_percentage}"
          set -g @nova-segment-battery-colors "$seg_b"

          set -g @nova-segments-0-left "session"
          set -g @nova-segments-0-right "prefix cpu ram battery"
        '';
      }
      {
        plugin = battery;
        extraConfig = ''
          set -g @batt_icon_charge_tier8 '󰂂'
          set -g @batt_icon_charge_tier7 '󰂀'
          set -g @batt_icon_charge_tier6 '󰁿'
          set -g @batt_icon_charge_tier5 '󰁾'
          set -g @batt_icon_charge_tier4 '󰁽'
          set -g @batt_icon_charge_tier3 '󰁼'
          set -g @batt_icon_charge_tier2 '󰁻'
          set -g @batt_icon_charge_tier1 '󰁺'
          set -g @batt_icon_status_charged '󱟢'
          set -g @batt_icon_status_charging '󰂄'
          set -g @batt_icon_status_discharging '󰂍'
        '';
      }
      cpu
    ];

    extraConfig = ''
      bind v split-window -v -c "#{pane_current_path}"
      bind s split-window -h -c "#{pane_current_path}"
      bind-key C-r rotate-window
      bind-key f resize-pane -Z

      # play nice with neovim in alacritty
      set -as terminal-features ',*:RGB'
      set -as terminal-overrides ',xterm-256color:RGB'
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      set-option -g renumber-windows on
    '';
  };
}
