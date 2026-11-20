{
  programs.steam = {
    enable = true;
    # Steam Input em jogos Wayland/XWayland e sessão gamescope no tuigreet.
    extest.enable = true;
    gamescopeSession.enable = true;
  };
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
