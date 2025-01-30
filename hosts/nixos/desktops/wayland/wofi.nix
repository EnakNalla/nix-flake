{
  vars,
  pkgs,
  ...
}: {
  home-manager.users.${vars.user}.home.packages = [pkgs.wofi];
}
