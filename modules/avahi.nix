{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = false;
      userServices = true;
      workstation = false;
    };
    openFirewall = true;
  };
}
