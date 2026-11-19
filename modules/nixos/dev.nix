{
  virtualisation.docker.enable = true;
  # Sem dockerCompat: o Docker de verdade já ocupa o comando `docker`.
  virtualisation.podman.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  users.users.seraphiine.extraGroups = [
    "docker"
    "libvirtd"
  ];
}
