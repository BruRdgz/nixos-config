{
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # Os mesmos flatpaks do Fedora atual, declarados.
  services.flatpak = {
    enable = true;
    packages = [
      "com.spotify.Client"
      "md.obsidian.Obsidian"
      "no.mifi.losslesscut"
      "org.kde.kdenlive"
      "org.prismlauncher.PrismLauncher"
      "org.vinegarhq.Sober"
      "org.vinegarhq.Vinegar"
    ];
  };
}
