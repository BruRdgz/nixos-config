# Disco 1: sistema. Disco 2: dados/jogos. Cada um com seu LUKS, então a falha de um
# não leva o outro. A mesma senha destrava os dois: o initrd systemd reaproveita a
# senha digitada.
# TODO(hardware): trocar os placeholders por /dev/disk/by-id/... da máquina real.
let
  btrfsOpts = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices.disk = {
    system = {
      type = "disk";
      device = "/dev/disk/by-id/PLACEHOLDER-disco-sistema";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptsystem";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = btrfsOpts;
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = btrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsOpts;
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = btrfsOpts;
                  };
                };
              };
            };
          };
        };
      };
    };

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
