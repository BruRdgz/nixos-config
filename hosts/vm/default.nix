# VM de teste (QEMU/KVM) que replica o desktop, incluindo a instalação via disko.
{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../desktop/disko.nix
    ../../modules/nixos
  ];

  networking.hostName = "desktop-vm";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Discos virtio com serial fixo no QEMU (serial=nixsys / serial=nixdata).
  disko.devices.disk.system.device = lib.mkForce "/dev/disk/by-id/virtio-nixsys";
  disko.devices.disk.data.device = lib.mkForce "/dev/disk/by-id/virtio-nixdata";

  # Senha da VM (LUKS e usuário): "nixos". O arquivo só é lido pelo disko ao formatar.
  disko.devices.disk.system.content.partitions.luks.content.passwordFile = "/tmp/luks.key";
  disko.devices.disk.data.content.partitions.luks.content.passwordFile = "/tmp/luks.key";
  users.users.seraphiine.initialPassword = "nixos";

  # Serial para automação; a janela gráfica continua recebendo o console.
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200"
  ];

  # Acesso do Claude por SSH durante o desenvolvimento (porta redirecionada pelo QEMU).
  users.users.seraphiine.openssh.authorizedKeys.keyFiles = [ ./claude-vm.pub ];
  services.openssh.openFirewall = lib.mkForce true;

  system.stateVersion = "26.11";
}
