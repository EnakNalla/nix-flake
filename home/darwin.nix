{
  mac-app-util,
  lib,
  config,
  ...
}:
{
  options.darwin = {
    enable = lib.mkEnableOption "Enable Darwin support";
  };

  config = lib.mkIf (config.darwin.enable) {
    imports = [
      mac-app-util.homeManagerModules.default
    ];
  };
}
