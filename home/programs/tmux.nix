{ pkgs, ... }:
{
  catppuccin.tmux = {
    enable = true;
    extraConfig = ''
      set -g @catppuccin_flavor "frappe"
      set -g @catppuccin_window_status_style "rounded"
    '';
  };

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
      # {
      #   plugin = dracula;
      #   extraConfig = ''
      #     set -g @dracula-plugins 'ram-usage cpu-usage battery git'
      #     set -g @dracula-show-battery-status true
      #
      #     set -g @dracula-show-flags true
      #     set -g @dracula-show-powerline true
      #
      #     set -g @dracula-cpu-usage-label ""
      #     set -g @dracula-ram-usage-label ""
      #   '';
      # }
    ];

    extraConfig = ''
      # set-option -g default-command "${pkgs.zsh}/bin/zsh" # not sure why this is needed, but it is

      # keybinds
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

      # catppuccin options that need to be set after the plugin is loaded
      set -g status-left ""
      set -g status-right '#[fg=#{@thm_crust},bg=#{@thm_teal}] session: #S '
      set -g status-right-length 100
    '';
  };
}
