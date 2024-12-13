/*
* This is for NVIDIA Optimus laptops.
* hardware.nvidia.enable = true;
*/
{
  config,
  pkgs,
  lib,
  ...
}: let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
  with lib; {
    options.hardware.nvidia = {
      enable = mkEnableOption "Enable NVIDIA hardware support";
    };

    config = mkIf (config.hardware.nvidia.enable) {
      nixpkgs.config.nvidia.acceptLicense = true;

      environment.systemPackages = [nvidia-offload];

      services.xserver.videoDrivers = ["nvidia"];
      hardware = {
        graphics.enable = true;
        nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.production;
          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
          };
          open = false;
          modesetting.enable = true;
          powerManagement = {
            enable = true;
            finegrained = true;
          };
        };
      };
    };
  }
