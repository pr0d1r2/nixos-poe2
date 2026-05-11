{
  pkgs,
  ...
}:

let
  poe2-launch = pkgs.writeShellApplication {
    name = "poe2-launch";
    runtimeInputs = with pkgs; [
      util-linux
      coreutils
      umu-launcher
      gamemode
    ];
    text = builtins.readFile ../pkgs/poe2-launch.sh;
  };

in
{
  environment.systemPackages = with pkgs; [
    umu-launcher
    winetricks
    poe2-launch
  ];

  # No firewall holes needed -- game traffic is outbound.
  networking.firewall.enable = true;
}
