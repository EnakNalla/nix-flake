{
  vars,
  inputs,
  ...
}:
{
  imports = [
    (if vars.host == "darwin" then inputs.mac-app-util.homeManagerModules.default else ./theme.nix)

    inputs.catppuccin.homeManagerModules.catppuccin

    ./files
  ] ++ import ./programs;

  catppuccin = {
    enable = true;
    flavor = "frappe";
    nvim.enable = false;
  };

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
