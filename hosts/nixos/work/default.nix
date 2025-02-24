{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [
    keepass
    openvpn
    php
  ];

  services.teamviewer.enable = true;

  fileSystems."/mnt/code" = {
    device = "/dev/disk/by-label/code";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
    ];
  };
}
