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
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "16G";
  };

  nixpkgs.config.allowUnfree = true;
}
