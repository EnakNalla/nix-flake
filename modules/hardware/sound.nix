{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alsa-utils # utilities for audio control
    pavucontrol # pulseaudio volume control
    pipewire # audio server
    pulseaudio # audio server
    qpwgraph # pulseaudio graph
  ];

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };
}
