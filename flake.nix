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
    # nh with darwin support (to remove once <https://github.com/LnL7/nix-darwin/pull/942>) merges
    nh.url = "github:viperML/nh";
    ####################################################

    ########### nixos specific flake inputs ###########
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    ####################################################

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      darwinConfigurations = (
        import ./hosts/darwin {
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
