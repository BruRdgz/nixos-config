# Provisório até o hardware chegar: substituir pelo resultado de
# `nixos-generate-config --no-filesystems --show-hardware-config` na máquina real
# (os sistemas de arquivos vêm do disko.nix).
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

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
}
