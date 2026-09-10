{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.supportedFilesystems.zfs = lib.mkForce false;
  hardware = {
    cpu.amd.updateMicrocode = true;

    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    enableRedistributableFirmware = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot = {
    # Default LTS, not linuxPackages_latest: Linux 7.2 dropped strncpy()
    # and no NVIDIA driver builds against it yet (SPEC C9, B15, T56).
    kernelPackages = pkgs.linuxPackages;
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "16G";
  };

  nixpkgs.config.allowUnfree = true;
}
