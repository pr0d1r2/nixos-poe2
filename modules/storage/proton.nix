{ pkgs, ... }:

{
  systemd.services.storage-proton = {
    description = "Create Proton compat data directory on storage";
    wantedBy = [ "multi-user.target" ];
    after = [ "storage-link.service" ];
    requires = [ "storage-link.service" ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = builtins.readFile ../../fragments/storage-proton.sh;
  };
}
