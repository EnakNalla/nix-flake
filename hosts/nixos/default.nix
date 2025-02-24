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
  laptop =
    let
      hostname = "laptop";
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs vars hostname;
        host.hostName = "laptop";
      };

      modules = [ ./laptop ] ++ modules;
    };

  work =
    let
      hostname = "work";
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs vars hostname;
        host.hostName = "work";
      };

      modules = [ ./work ] ++ modules;
    };
}
