{ lib, pkgs, ... }:

let
  raw = builtins.readFile ../secrets/authorized_keys;
  lines = lib.splitString "\n" raw;
  keys = builtins.filter (l: l != "" && !lib.hasPrefix "#" l) lines;
in
{
  users = {
    users.player = {
      isNormalUser = true;
      uid = 1000;
      group = "player";
      description = "Path of Exile 2";
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "input"
      ];
      initialHashedPassword = "";
      openssh.authorizedKeys.keys = keys;
      shell = pkgs.bashInteractive;
    };
    groups.player.gid = 1000;

    users.nixos = {
      isNormalUser = lib.mkForce false;
      isSystemUser = lib.mkForce true;
      group = "nixos";
    };
    groups.nixos = { };
  };

  services.getty.autologinUser = lib.mkForce "player";
}
