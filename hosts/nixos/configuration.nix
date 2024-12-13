{
  pkgs,
  inputs,
  vars,
  ...
}: let
  terminal = pkgs.${vars.terminal};
in {
  /*
  nix
  */
  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];

    config.allowUnfree = true;
  };

  nix = {
    settings.auto-optimise-store = true;

    registry.nixpkgs.flake = inputs.nixpkgs;

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };

  /*
  user
  */
  programs.zsh.enable = true;
  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio" "docker"];
    shell = pkgs.zsh;
  };

  /*
  language
  */
  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  console.keyMap = "uk";

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = ["JetBrainsMono"];
    })
  ];

  /*
  system
  */
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--delete-older-than 2d";
      dates = "weekly";
    };
    flake = "${vars.flake}";
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "${vars.terminal}";
      FLAKE = "${vars.flake}"; # for nh
    };

    sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_8}"; # required for global tools
    };

    systemPackages = with pkgs; [
      /*
      system utils
      */
      coreutils # gnu core utils
      htop # tui system monitor
      terminal
      git
      brightnessctl # control backlight
      fzf # fuzzy finder
      neovim # text editor

      /*
      apps
      */
      firefox
      brave
      spotify

      /*
      audio/video
      */
      feh # image viewer
      linux-firmware
      mpv # video player

      /*
      file management
      */
      zip
      unzip
      ripgrep
      file-roller # archive manager
      pcmanfm # file manager
      fd # find files

      /*
      dev
      */
      zulu17 # jdk
      inputs.alejandra.defaultPackage.${system} # nix formatter
      nil # .nix lsp
      nodejs_20 # node lts
      yarn # node package manager
      eslint_d # eslint
      prettierd # prettier
      gcc
      dotnet-sdk_8
      jetbrains.rider
      cargo # rust
      lazygit # git tui
      androidStudioPackages.dev # needs to be dev right now (2024.2.2 has wayland support)
      go
    ];
  };

  programs.nix-ld.enable = true; # mainly for vscode extensions

  virtualisation.docker = {
    enable = true;

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  networking = {
    hostName = "laptop";
    networkmanager.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # passwordless sudo
  };

  programs.dconf.enable = true;

  system.stateVersion = "24.05";
}
