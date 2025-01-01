{ inputs, nixpkgs, ... }:
let
  vars = {
    user = "enak";
    home = "/Users/enak";
    terminal = "alacritty";
    flake = "/Users/enak/nix-darwin";
    host = "darwin";
  };

  system = "aarch64-darwin";

  lib = inputs.darwin.lib;

  modules = [
    inputs.mac-app-util.darwinModules.default
    # nh with darwin support (to remove once <https://github.com/LnL7/nix-darwin/pull/942>) merges
    ./nh.nix

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${vars.user} = import ../../home;
      home-manager.extraSpecialArgs = {
        inherit inputs vars;
      };
    }

    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = "${vars.user}";
      };
    }

    inputs.catppuccin.nixosModules.catppuccin

    ../../modules/catppuccin.nix
    ./configuration.nix
  ];
in
{
  mac = lib.darwinSystem {
    inherit system;

    specialArgs = {
      inherit inputs vars nixpkgs;
      host.hostName = "mac";
    };

    modules = modules;
  };
}
