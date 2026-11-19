{
  imports = [
    ./hardware.nix
    ./disk-system.nix
    ./disk-data.nix
    ../../modules/nixos
  ];

  networking.hostName = "desktop";

  # O disco de dados entra no backup; os jogos se baixam de novo.
  services.restic.backups.home = {
    paths = [ "/data" ];
    exclude = [ "/data/games" ];
  };

  # Fixar na release vigente no dia da instalação real e nunca mais mudar.
  system.stateVersion = "26.11";
}
