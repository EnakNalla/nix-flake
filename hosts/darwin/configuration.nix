{
  pkgs,
  inputs,
  ...
}: {
  # System config
  nixpkgs = {
    hostPlatform = "aarch64-darwin";

    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];

    config.allowUnfree = true;
  };

  nix.settings.experimental-features = "nix-command flakes";

  services.nix-daemon.enable = true;

  system = {
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        _HIHideMenuBar = true;
      };

      dock = {
        autohide = true;
        show-recents = false;
        persistent-apps = [
          "${pkgs.alacritty}/Applications/Alacritty.app"
          "/Applications/Safari.app"
        ];
      };

      menuExtraClock.ShowSeconds = true;

      loginwindow.GuestEnabled = false;

      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
        FXPreferredViewStyle = "clmv"; # column view
        FXDefaultSearchScope = "SCcf"; # search in current folder
        CreateDesktop = false; # disable desktop icons
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };

      trackpad.Clicking = true; # tap to click

      CustomUserPreferences = {
        "com.apple.finder" = {
          FinderSpawnTab = true;
        };
        # Show battery percentage
        "~/Library/Preferences/ByHost/com.apple.controlcenter".BatteryShowPercentage = true;
        # Privacy
        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
      };
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

  programs.zsh.enable = true;

  users.users.enak = {
    home = "/Users/enak";
    shell = pkgs.zsh;
  };

  networking = {
    hostName = "mac";
    computerName = "mac";
  };

  # apps & services
  environment = {
    darwinConfig = "/Users/enak/nix-darwin";
    systemPackages = with pkgs; [
      # utilities
      fzf # fuzzy finder
      mkalias # needed so spotlight can index apps
      mas # mac app store cli
      ripgrep # recursive regex
      sketchybar-app-font
      fd
      gimp
      eza

      # dev
      # neovim
      nil # .nix lsp
      dotnet-sdk_8
      lazygit # git tui
      cargo
      zulu17
      jetbrains.phpstorm
      prettierd
    ];
  };

  # for programs unavailable via nix
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    brews = [
      "nvm" # node version manager
      "watchman"
      "sketchybar"
    ];

    casks = [
      "google-chrome"
      "docker"
      "android-studio"
      "alfred"
      "cleanmymac"
      "stats"
      "launchcontrol"
      "sf-symbols"
      "zen-browser"
      "discord"
      "aerospace"
    ];

    masApps = {
      "Xcode" = 497799835;
      "Bitwarden" = 1352778147;
      "Vimari" = 1480933944;
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  services = {
    # Can't use aerospace & sketchybar as nix services because then they don't play well together. Only way I found to make it work is both as homebrew packages.
    # aerospace = {
    #   enable = true;

    #   settings = {
    #     mode.main.binding = {
    #       alt-h = "focus left";
    #       alt-j = "focus down";
    #       alt-k = "focus up";
    #       alt-l = "focus right";

    #       alt-shift-h = "move left";
    #       alt-shift-j = "move down";
    #       alt-shift-k = "move up";
    #       alt-shift-l = "focus right";

    #       alt-shift-minus = "resize smart -50";
    #       alt-shift-equal = "resize smart +50";

    #       alt-f = "fullscreen";
    #       alt-t = "layout floating tiling";

    #       alt-1 = "workspace 1";
    #       alt-2 = "workspace 2";
    #       alt-3 = "workspace 3";
    #       alt-4 = "workspace 4";
    #       alt-5 = "workspace 5";

    #       alt-shift-1 = ["move-node-to-workspace 1" "workspace 1"];
    #       alt-shift-2 = ["move-node-to-workspace 2" "workspace 2"];
    #       alt-shift-3 = ["move-node-to-workspace 3" "workspace 3"];
    #       alt-shift-4 = ["move-node-to-workspace 4" "workspace 4"];
    #       alt-shift-5 = ["move-node-to-workspace 5" "workspace 5"];

    #       alt-shift-semicolon = "mode service";
    #     };

    #     mode.service.binding = {
    #       esc = ["reload-config" "mode main"];
    #       r = ["flatten-workspace-tree" "mode main"];
    #       f = ["layout floating tiling" "mode main"];
    #       t = ["layout tiles horizontal vertical" "mode main"];
    #       a = ["layout accordion horizontal vertical" "mode main"];
    #     };

    #     after-startup-command = [
    #       "exec-and-forget /opt/homebrew/opt/sketchybar/bin/sketchybar"
    #     ];

    #     exec-on-workspace-change = [
    #       "/bin/bash"
    #       "-c"
    #       "/opt/homebrew/opt/sketchybar/bin/sketchybar --trigger aerospace_workspace_change AEROSPACE_FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE AEROSPACE_PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
    #     ];

    #     exec = {
    #       inherit-env-vars = true;
    #       env-vars = {
    #         PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:\${PATH}";
    #       };
    #     };

    #     default-root-container-layout = "tiles";
    #     default-root-container-orientation = "auto";

    #     gaps = {
    #       inner.horizontal = 20;
    #       inner.vertical = 20;
    #       outer.left = 15;
    #       outer.right = 15;
    #       outer.top = 15;
    #       outer.bottom = 15;
    #     };
    #   };
    # };

    # config managed by home manager files (I don't know how to do it here.)
    # sketchybar.enable = true;

    jankyborders = {
      enable = true;

      hidpi = false;
      active_color = "0xffBD93F9";
      inactive_color = "0xff44475A";
      background_color = "0xff282a36";
      width = 6.0;
      style = "round";
    };
  };
}
