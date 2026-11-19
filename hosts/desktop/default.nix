{
  imports = [
    ./hardware.nix
    ./disk-system.nix
    ./disk-data.nix
    ../../modules/nixos
  ];

  networking.hostName = "desktop";

  # Fixar na release vigente no dia da instalação real e nunca mais mudar.
  system.stateVersion = "26.11";
}
