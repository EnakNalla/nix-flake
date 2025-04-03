{ inputs, ... }:
let
  vars = {
    user = "enak";
    terminal = "alacritty";
    flake = "/Users/enak/nix-flake";
    home = "/Users/enak";
    host = "darwin";
  };

  system = "aaarch64-darwin";

  modules = [
    # nh with darwin support (to remove once <https://github.com/LnL7/nix-darwin/pull/942>) merges
    ./nh.nix

    inputs.mac-app-util.darwinModules.default

    inputs.stylix.darwinModules.stylix

    inputs.home-manager.nixosModules.default
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs vars;
      };
      home-manager.users.${vars.user} = import ../../home;
    }

    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = "${vars.user}";
      };
    }

    ./configuration.nix
  ];
in
{
  mac = inputs.darwin.lib.darwinSystem {
    inherit system;

    specialArgs = {
      inherit inputs vars;
      host.hostName = "mac";
    };

    modules = modules;
  };
}
