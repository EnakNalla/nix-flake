{
  vars,
  mac-app-util,
  ...
}:
{
  imports = [
    (if vars.host == "darwin" then mac-app-util.homeManagerModules.default else ./theme.nix)

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
