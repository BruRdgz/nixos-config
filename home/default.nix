{
  imports = [
    ./shell.nix
    ./dev.nix
    ./hyprland.nix
    ./theme.nix
  ];

  home.username = "seraphiine";
  home.homeDirectory = "/home/seraphiine";

  # Mesma regra do system.stateVersion: fixar na instalação e não mudar.
  home.stateVersion = "26.11";
}
