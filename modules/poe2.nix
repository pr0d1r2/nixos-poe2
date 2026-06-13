{
  pkgs,
  ...
}:

let
  poe2-resolve-exe = pkgs.writeShellApplication {
    name = "poe2-resolve-exe";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ../pkgs/poe2-resolve-exe.sh;
  };

  poe2-launch = pkgs.writeShellApplication {
    name = "poe2-launch";
    runtimeInputs = with pkgs; [
      util-linux
      coreutils
      umu-launcher
      gamemode
      poe2-resolve-exe
    ];
    text = builtins.readFile ../pkgs/poe2-launch.sh;
  };

in
{
  environment.systemPackages = with pkgs; [
    umu-launcher
    winetricks
    poe2-launch
    poe2-resolve-exe
  ];

  # No firewall holes needed -- game traffic is outbound.
  networking.firewall.enable = true;
}
