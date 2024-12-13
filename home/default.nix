{mac-app-util, vars, ...}: {
  imports =
    [
      mac-app-util.homeManagerModules.default

      ./files
    ]
    ++ import ./programs;

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
