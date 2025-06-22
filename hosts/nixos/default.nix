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
        host.hostName = hostname;
      };

      modules = [
        ./laptop

        inputs.home-manager.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs vars hostname;
          };
          home-manager.users.${vars.user} = import ../../home;
        }

      ] ++ modules;
    };

  work =
    let
      hostname = "work";
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs vars hostname;
        host.hostName = hostname;
      };

      modules = [
        ./work

        inputs.home-manager.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs vars hostname;
          };
          home-manager.users.${vars.user} = import ../../home;
        }

      ] ++ modules;
    };
}
