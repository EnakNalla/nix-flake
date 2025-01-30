# shared config for all nixos hosts
{
  inputs,
  vars,
  pkgs,
  ...
}:
{
  # boot
  boot = {
    tmp = {
      cleanOnBoot = true;
      tmpfsSize = "5GB";
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };

      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
  };

  # nix configuration
  nixpkgs = {
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];

    config.allowUnfree = true;
  };

  nix = {
    optimise.automatic = true;

    registry.nixpkgs.flake = inputs.nixpkgs;

    extraOptions = ''
      experimental-features = nix-command flakes
              keep-outputs          = true
              keep-derivations      = true
    '';
  };

  # user setup
  programs.zsh.enable = true;
  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "docker"
    ];
    shell = "${pkgs.zsh}/bin/zsh";
  };

  # localisation
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

  # system level config
  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "${vars.terminal}";
      FLAKE = "${vars.flake}";
    };

    sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_8}"; # required for global nuget packages
    };

    systemPackages = with pkgs; [
      # system utilities
      coreutils # gnu
      git
      brightnessctl # control backlight
      eza # ls replacement
      neovim # goat editor
      linux-firmware
      sysstat
      acpi

      # apps
      brave # need a chromium based browser for react-native
      spotify
      librewolf

      # audio/video
      feh # image viewer
      mpv # video player
      alsa-utils # utilities for audio control
      pavucontrol # pulseaudio volume control
      pipewire # audio server
      pulseaudio # audio server
      qpwgraph # pulseaudio graph

      # file management
      zip
      unzip
      ripgrep
      fzf # fuzzy finder
      file-roller # archive manager
      fd # find replacement

      # dev
      zulu17 # jdk
      nil # nix lsp
      statix
      nixfmt-rfc-style
      nodejs_22 # lts node
      eslint_d
      prettierd
      gcc
      cargo # rust
      dotnet-sdk_8
      lazygit # git tui
      pnpm # node package manager
      android-studio
    ];
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs = {
    nix-ld.enable = true; # needed for some vscode extensions & lazyvim
    dconf.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--delete-older-than 2d";
        dates = "daily";
      };
      flake = "${vars.flake}";
    };
  };

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
    enableIPv6 = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        8081
        8080
      ];
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # passwordless sudo
  };

  system.stateVersion = "24.05";

  #hardware
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    blueman.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoEnable = true;
        ControllerMode = "bredr";
      };
    };
  };

  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

    cursor = {
      package = pkgs.catppuccin-cursors.frappeBlue;
      name = "catppuccin-frappe-blue-cursors";
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };

    image = ../../wall.png;
  };
}
