_:

{
  # Stable machine-id derived from: echo -n "nixos-poe2" | md5sum
  environment.etc."machine-id" = {
    text = "a15d0224aec0dee8a812d0f34370c7d2\n";
    mode = "0444";
  };
}
