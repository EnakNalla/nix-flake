{ pkgs, ... }: {
  imports = [./hardware-configuration.nix];

  hardware.nvidia.enable = true;

  environment.systemPackages = with pkgs; [
    fprintd
  ];

  # sudo fprintd-enroll --finger right-index-finger <user>
  services.fprintd.enable = true;
}
