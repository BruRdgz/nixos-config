# Disco 1: sistema (ESP + LUKS com btrfs).
# TODO(hardware): trocar o placeholder por /dev/disk/by-id/... da máquina real.
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
  };
}
