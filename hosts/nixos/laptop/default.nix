{ pkgs, config, ... }:
let
	 nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    		export __NV_PRIME_RENDER_OFFLOAD=1
    		export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    		export __GLX_VENDOR_LIBRARY_NAME=nvidia
    		export __VK_LAYER_NV_optimus=NVIDIA_only
    		exec "$@"
  	'';
in
{
	imports = [ ./hardware-configuration.nix ];

	environment.systemPackages = with pkgs; [
		fprintd
		nvidia-offload
	];

	# sudo fprintd-enroll --finger right-index-finger <user>
	services.fprintd.enable = true;

	# nvidia optimus
	nixpkgs.config.nvidia.acceptLicense = true;

	services.xserver.videoDrivers = [ "nvidia" ];

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
			modesetting.enable = false;
			powerManagement = {
				enable = true;
				finegrained = true;
			};
		};
	};
}
