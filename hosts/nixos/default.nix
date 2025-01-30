{ inputs, ... }:
let
  vars = {
    user = "enak";
    terminal = "alacritty";
    flake = "/home/enak/nix-flake";
    home = "/home/enak";
    host = "nixos";
  };

  system = "x86_64-linux";

  modules = [
    inputs.home-manager.nixosModules.default
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs vars;
      };
      home-manager.users.${vars.user} = import ../../home;
    }

    ./configuration.nix

    inputs.stylix.nixosModules.stylix
  ] ++ import ./desktops/wayland;
in
{
  laptop = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs vars;
      host.hostName = "laptop";
    };

    modules = [ ./laptop ] ++ modules;
  };

  work = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs vars;
      host.hostName = "laptop";
    };

    modules = [ ./work ] ++ modules;
  };
}
