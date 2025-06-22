{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [
    keepassxc
    php
    bear
    cifs-utils
    nrf-udev
    nrfutil
    wireshark
    dos2unix
    wget
    subversion
  ];

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8 * 1024;
    } # size is in MiB, so 8GB = 8 * 1024 MiB
  ];

  services.udev.extraRules = ''
    # unload ftdi_sio driver for hyper racks
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", ATTR{manufacturer}=="FTDI", ENV{ID_MODULE}="ftdi_sio"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", DRIVER=="ftdi_sio", RUN+="/bin/sh -c 'echo -n $kernel > /sys/bus/usb/drivers/ftdi_sio/unbind'"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", GROUP="dialout", MODE="0666"

    # allow non-root users to access tty
    KERNEL=="ttyACM[0-9]*", GROUP="dialout", MODE="0660"
  '';

  services.teamviewer.enable = true;

  systemd.services.teamviewer-post-boot-restart = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "default.target"
    ];
    script = ''
      systemctl restart teamviewerd
    '';
    serviceConfig.Type = "oneshot";
  };

  services.openvpn = {
    servers = {
      work = {
        config = "/mnt/code/.keys/OpenVPN/config/DundeeVPN.ovpn";
        autoStart = false;
      };
    };
  };

  fileSystems."/mnt/code" = {
    device = "/dev/disk/by-label/code";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
    ];
  };

  nixpkgs.config.segger-jlink.acceptLicense = true;

  fileSystems."/mnt/datafiles" = {
    device = "//192.168.3.253/datafiles";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets" ];
  };

  fileSystems."/mnt/memset_backups" = {
    device = "//192.168.3.253/memset";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets" ];
  };

  networking.extraHosts = ''
    192.168.3.253 serialnumbers.local
  '';
}
