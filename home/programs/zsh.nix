{ pkgs, vars, ... }:
let
  zshExtras =
    if vars.host == "darwin" then
      ''
        # android
        PATH="$HOME/Library/Android/sdk/platform-tools:$PATH" # adds adb to path
        export ANDROID_HOME="$HOME/Library/Android/sdk"

        PATH="$PATH:/opt/homebrew"
      ''
    else
      ''
        # android
        PATH="$HOME/Android/Sdk/platform-tools:$PATH"
        export ANDROID_HOME="$HOME/Android/Sdk"
      '';
in
{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    historySubstringSearch = {
      enable = true;
      searchUpKey = "^n";
      searchDownKey = "^p";
    };

    prezto = {
      enable = true;
      tmux = {
        autoStartLocal = true;
      };
    };

    shellAliases = {
      vim = "nvim";
      c = "clear";
      ls = "eza --icons=always";
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/zsh/plugins/zsh-fzf-tab/zsh-fzf-tab.plugin.zsh";
      }
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    initExtra = ''
      if [ Darwin = `uname` ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      # functions
      function killport() {
        lsof -i tcp:$1 | awk 'NR!=1 {print $2}' | xargs kill
      }

      function mkcd() {
        mkdir -p $1 && cd $1
      }

      # shell integrations
      zvm_after_init_commands+=('eval "$(fzf --zsh)"')

      ${zshExtras}

      export NVM_DIR="$HOME/.nvm"
      PATH="$PATH:$HOME/.dotnet/tools"

      [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
      [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      version = 2;
      final_space = true;
      console_title_template = "{{ .Shell }} in {{ .Folder }}";

      blocks = [
        {
          type = "prompt";
          alignment = "left";
          newline = true;

          segments = [
            {
              type = "path";
              style = "plain";
              background = "transparent";
              foreground = "purple";
              template = "{{ .Path }}";
              properties = {
                style = "full";
              };
            }
            {
              type = "git";
              style = "plain";
              foreground = "p:grey";
              background = "transparent";
              template = " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>";
              properties = {
                branch_icon = "";
                commit_icon = "@";
                fetch_status = true;
              };
            }
          ];
        }
        {
          type = "rprompt";
          overflow = "hidden";

          segments = [
            {
              type = "executiontime";
              style = "plain";
              foreground = "yellow";
              background = "transparent";
              template = " {{ .FormattedMs }}";

              properties = {
                threshold = 1000;
              };
            }
          ];
        }
        {
          type = "prompt";
          alignment = "left";
          newline = true;

          segments = [
            {
              type = "text";
              style = "plain";
              foreground_templates = [
                "{{if gt .Code 0}}red{{end}}"
                "{{if eq .Code 0}}magenta{{end}}"
              ];
              background = "transparent";
              template = "❯";
            }
          ];
        }
      ];
      transient_prompt = {
        foreground_templates = [
          "{{if gt .Code 0}}red{{end}}"
          "{{if eq .Code 0}}magenta{{end}}"
        ];
        background = "transparent";
        template = "❯ ";
      };

      secondary_prompt = {
        foreground = "magenta";
        background = "transparent";
        template = "❯❯ ";
      };
    };
  };
}
