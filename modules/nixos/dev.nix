{
  virtualisation.docker.enable = true;
  # Sem dockerCompat: o Docker de verdade já ocupa o comando `docker`.
  virtualisation.podman = {
    enable = true;
    # Containers na rede padrão se encontram pelo nome.
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    # TPM emulado (VMs de Windows 11).
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  users.users.seraphiine.extraGroups = [
    "docker"
    "libvirtd"
    "kvm"
  ];
}
