{ lib, pkgs, ... }:

let
  configDir = ../config/user;
  readConfig =
    file: default:
    if builtins.pathExists (configDir + "/${file}") then
      lib.strings.trim (builtins.readFile (configDir + "/${file}"))
    else
      default;
in
{
  image.baseName = lib.mkForce "nixos-poe2";

  networking = {
    hostName = "poe2";
    domain = "local";
    networkmanager.enable = true;
  };

  time.timeZone = lib.mkDefault (readConfig "timezone" "Europe/Warsaw");
  i18n.defaultLocale = readConfig "locale" "en_US.UTF-8";
  console.keyMap = readConfig "keymap" "us";

  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      desktopManager.xterm.enable = false;
    };

    timesyncd.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      openbox
      xorg.xinit
      xorg.xrandr
      xorg.xset
      util-linux
      coreutils
      e2fsprogs
      pciutils
      usbutils
      htop
      mangohud
    ];

    etc."skel/.bash_profile".text = builtins.readFile ../fragments/bash-profile.sh;

    etc."skel/.xinitrc".text = ''
      #!/bin/sh
      ${pkgs.openbox}/bin/openbox &
      ${pkgs.xorg.xset}/bin/xset s off
      ${pkgs.xorg.xset}/bin/xset -dpms
      ${pkgs.xorg.xset}/bin/xset s noblank
      exec poe2-launch
    '';
  };
}
