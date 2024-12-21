{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;

    prefix = "C-Space";
    keyMode = "vi";

    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins 'ram-usage cpu-usage battery git'
          set -g @dracula-show-battery-status true

          set -g @dracula-show-flags true
          set -g @dracula-show-powerline true

          set -g @dracula-cpu-usage-label ""
          set -g @dracula-ram-usage-label ""
        '';
      }
    ];

    extraConfig = ''
      set-option -g default-command "${pkgs.zsh}/bin/zsh" # not sure why this is needed, but it is

      # keybinds
      bind v split-window -v -c "#{pane_current_path}"
      bind s split-window -h -c "#{pane_current_path}"
      bind-key C-r rotate-window
      bind-key f resize-pane -Z

      # play nice with neovim in alacritty
      set -g default-terminal 'screen-256color'
      set -ga terminal-overrides ',*256col*:Tc'
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'

      set-option -g renumber-windows on
    '';
  };
}
