{
  vars,
  inputs,
  ...
}:
let
  imports = if vars.host == "darwin" then
   [inputs.mac-app-util.homeManagerModules.default] ++ import ./programs
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

  programs.home-manager.enable = true;
}
