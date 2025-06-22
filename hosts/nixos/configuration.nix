# shared config for all nixos hosts
{
  inputs,
  vars,
  pkgs,
  hostname,
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
      "dialout"
      "tty"
      "adbusers"
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
      BROWSER = "${pkgs.librewolf}/bin/librewolf";
      # you need to open android-studio and follow the setup wizard to get this path :(
      ANDROID_HOME = "${vars.home}/Android/Sdk";
      PATH = "${vars.home}/go/bin:$PATH";
    };

    sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_8}/share/dotnet"; # required for global nuget packages
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
      lsof
      usbutils
      nnn # tui file explorer

      # apps
      ungoogled-chromium # need a chromium based browser for react-native
      librewolf
      vesktop

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
      cargo # rust
      dotnet-sdk_8
      lazygit # git tui
      pnpm # node package manager
      android-studio
      csharpier
      cmake
      ninja
      gcc
      autoconf
      udev
      automake
      libtool
      ncdu
    ];
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs = {
    nix-ld.enable = true; # needed for some vscode extensions & lazyvim
    dconf.enable = true;

    adb.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--delete-older-than 2d --keep 2";
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
      daemon.settings = {
        # userland-proxy = false;
        ipv6 = false;
        # dns = [ "192.168.1.1" ];
        dns = [
          "8.8.8.8"
          "1.1.1.1"
        ];
      };
    };
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;

      wifi.powersave = false;
    };

    nameservers = [ "192.168.1.1" ];

    enableIPv6 = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        8000
        8081 # expo
        8080 # dev server
        3000 # dev client
        9003 # xdebug
        8443
        5173
      ];
      extraCommands = ''
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';
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
    resolved.enable = true; # dns caching

    udisks2.enable = true; # disk management

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
      size = 24;
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
