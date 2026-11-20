# VM de teste (virt-manager, UEFI, virtio-gpu 3D) que replica o desktop.
# Só tem o disco de sistema; o repo chega por virtiofs.
{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../desktop/disk-system.nix
    ../../modules/nixos
  ];

  networking.hostName = "desktop-vm";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Disco virtio com serial "nixsys" no virt-manager.
  disko.devices.disk.system.device = lib.mkForce "/dev/disk/by-id/virtio-nixsys";

  # Senha do LUKS na VM: "nixos". O arquivo só é lido pelo disko ao formatar.
  # (A senha do usuário vem do sops: secrets/secrets.yaml.)
  disko.devices.disk.system.content.partitions.luks.content.passwordFile = "/tmp/luks.key";

  # O repo do host, editado pelo Claude e aplicado aqui com nixos-rebuild.
  fileSystems."/home/seraphiine/nixos-config" = {
    device = "nixos-config";
    fsType = "virtiofs";
    options = [ "nofail" ];
  };

  services.spice-vdagentd.enable = true;

  # Acesso do Claude por SSH durante o desenvolvimento.
  users.users.seraphiine.openssh.authorizedKeys.keyFiles = [ ./claude-vm.pub ];
  users.users.root.openssh.authorizedKeys.keyFiles = [ ./claude-vm.pub ];
  services.openssh.openFirewall = lib.mkForce true;
  # Acesso de desenvolvimento por chave (o desktop proíbe login de root).
  services.openssh.settings = {
    PermitRootLogin = lib.mkForce "prohibit-password";
    AllowUsers = lib.mkForce [
      "seraphiine"
      "root"
    ];
  };

  system.stateVersion = "26.11";
}
