# Disco 2: dados/jogos, com LUKS próprio para que a falha de um disco não leve o outro.
# TODO(hardware): trocar o placeholder por /dev/disk/by-id/... da máquina real.
let
  btrfsOpts = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk = {
    data = {
      type = "disk";
      device = "/dev/disk/by-id/PLACEHOLDER-disco-dados";
      content = {
        type = "gpt";
        partitions.luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptdata";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@data" = {
                  mountpoint = "/data";
                  mountOptions = btrfsOpts;
                };
                "@games" = {
                  mountpoint = "/data/games";
                  mountOptions = btrfsOpts;
                };
              };
            };
          };
        };
      };
    };
  };
}
