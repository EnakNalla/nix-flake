{ inputs, nixpkgs, ... }:
let
  vars = {
    user = "enak";
    terminal = "alacritty";
    flake = "/home/enak/nix";
  };

  system = "x86_64-linux";

  lib = inputs.nixpkgs.lib;

  modules = [
    inputs.home-manager.nixosModules.home-manager
    {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs vars;
        };
        home-manager.users.${vars.user} = import ../../home;
    }

    ./configuration.nix
  ] ++ (import ../../modules);
in {
  laptop = lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs vars nixpkgs;
      host.hostName = "laptop";
    };

    modules = [./laptop] ++ modules;
  };

  work = lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs vars nixpkgs;
      host.hostName = "work";
    };

    modules = [./work] ++ modules;
  };
}
