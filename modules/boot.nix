{
  boot = {
    tmp = {
      cleanOnBoot = true;
      tmpfsSize = "5GB";
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
  };
}
