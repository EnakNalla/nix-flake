{
  vars,
  inputs,
  ...
}:
let
  imports =
    if vars.host == "darwin" then
      [ inputs.mac-app-util.homeManagerModules.default ] ++ import ./programs
    else
      import ./programs;
in
{
  imports = imports;

  home = {
    username = vars.user;
    homeDirectory = vars.home;
    stateVersion = "24.05";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
    };
  };

  programs.home-manager.enable = true;
}
