{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mumble
    wmctrl
  ];

  environment.etc."xdg/openbox/rc.xml".source = ../fragments/openbox-rc.xml;
}
