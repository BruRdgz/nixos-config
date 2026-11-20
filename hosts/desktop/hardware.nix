# Provisório até o hardware chegar: substituir pelo resultado de
# `nixos-generate-config --no-filesystems --show-hardware-config` na máquina real
# (os sistemas de arquivos vêm do disko.nix).
{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  # KMS precoce: a tela já sai na resolução nativa no Plymouth/senha do LUKS.
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Adaptador USB Wi-Fi + Bluetooth Realtek RTL8821CU (driver rtw88_8821cu, já no
  # kernel). Ele liga em modo CD-ROM (0bda:1a2b) e precisa ser trocado para o modo
  # de rede (0bda:c820); regra herdada do config antigo.
  hardware.usb-modeswitch.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="1a2b", \
      RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v 0bda -p 1a2b"
  '';
}
