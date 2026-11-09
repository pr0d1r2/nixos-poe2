{ lib, pkgs, ... }:

let
  # CVE-2026-99281 (tun: CAP_NET_ADMIN to attach to an ownerless device)
  # is fixed in 6.18.61. nixos-26.05 still ships 6.18.60, so pin the
  # source ahead of the channel until it catches up (SPEC B17, T57, V47).
  # Hash from nixpkgs release-26.05 kernels-org.json.
  fixedIn = "6.18.61";
  pinned = pkgs.linux_6_18.override {
    argsOverride = rec {
      version = "6.18.62";
      modDirVersion = version;
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
        sha256 = "0lfnsycp12j4j2sldjjf0s1dmdfcrhrm7h56sdjwamdky7npl2j9";
      };
    };
  };
in
{
  # Default LTS, not linuxPackages_latest: Linux 7.2 dropped strncpy()
  # and no NVIDIA driver builds against it yet (SPEC C9, B15, T56).
  # The pin drops itself once the channel's 6.18 reaches fixedIn.
  boot.kernelPackages =
    if lib.versionOlder pkgs.linux_6_18.version fixedIn then
      pkgs.linuxPackagesFor pinned
    else
      pkgs.linuxPackages;
}
