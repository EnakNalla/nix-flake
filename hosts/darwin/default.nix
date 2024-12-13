{ inputs, nixpkgs, ... }:
let
  vars = {
    user = "enak";
    home = "/Users/enak";
    terminal = "alacritty";
  };

  system = "aarch64-darwin";

  lib = inputs.darwin.lib;

  mac-app-util = inputs.mac-app-util;
  modules = [
    inputs.mac-app-util.darwinModules.default

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.enak = import ../../home;
      home-manager.extraSpecialArgs = {
        inherit mac-app-util vars;
      };
    }

    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = "enak";
      };
    }

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
