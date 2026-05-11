{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.pulsemixer ];

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  services.pipewire.extraConfig.pipewire."10-combine-sinks" = {
    "context.modules" = [
      {
        name = "libpipewire-module-combine-stream";
        args = {
          "combine.mode" = "sink";
          "node.name" = "combine-all";
          "node.description" = "All Outputs";
          "combine.latency-compensate" = false;
          "combine.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
            "priority.session" = 2000;
          };
          "stream.rules" = [
            {
              matches = [
                {
                  "media.class" = "Audio/Sink";
                }
              ];
              actions = {
                "create-stream" = { };
              };
            }
          ];
        };
      }
    ];
  };
}
