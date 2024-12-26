{ vars, ... }:
{
  imports = [
    ./darwin.nix

    ./files
  ] ++ import ./programs;

  home = {
    username = vars.user;
    homeDirectory = vars.home;
    stateVersion = "24.05";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  programs.home-manager.enable = true;
}
