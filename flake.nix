{
  description = "Enak's system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    ########### darwin specific flake inputs ###########
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    ####################################################
    
    ########### nixos specific flake inputs ###########
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    ####################################################

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = {self, nixpkgs, ...} @ inputs: {
    darwinConfigurations = (
      import ./hosts/darwin {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs;
      }
    );

    nixosConfigurations = (
      import ./hosts/nixos {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs;
      }
    );
  };
}