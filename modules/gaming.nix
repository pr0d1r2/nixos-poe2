{ lib, pkgs, ... }:

{
  programs.gamemode.enable = true;

  systemd.services.poe2-seed-home = {
    description = "Bind-mount player home from storage and seed dotfiles"; # nolocalpath
    wantedBy = [ "multi-user.target" ];
    after = [ "storage-link.service" ];
    requires = [ "storage-link.service" ];
    before = [ "getty@tty1.service" ];
    path = [
      pkgs.coreutils
      pkgs.util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = builtins.readFile ../fragments/seed-home.sh;
  };

  security.pam.services.login.rules.session.lastlog.enable = lib.mkForce false;

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
