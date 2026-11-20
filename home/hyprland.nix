{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # O UWSM (habilitado no sistema) já cuida da sessão systemd.
    systemd.enable = false;
    # Config em Lua (formato atual do Hyprland), escrita à mão: mais legível que gerar Lua a partir de Nix.
    configType = "lua";
    extraConfig = builtins.readFile ./files/hypr/hyprland.lua;
  };

  # Opção xkb custom, a mesma do Fedora; o libxkbcommon lê ~/.config/xkb.
  xdg.configFile."xkb/compat/custom".source = ./files/xkb/compat/custom;
  xdg.configFile."xkb/rules/evdev".source = ./files/xkb/rules/evdev;

  programs.kitty.enable = true;
  programs.fuzzel.enable = true;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };
  services.hyprpolkitagent.enable = true;
  services.hyprpaper.enable = true;

  programs.hyprlock.enable = true;
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    playerctl
    pavucontrol
    nautilus
    hyprshot
    # Apps
    brave
    discord
    mpv
    imv
    zathura
    obs-studio
    baobab
  ];

  # Pastas do usuário em português, como no Fedora (o Super+Print salva em ~/Imagens).
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Área de trabalho";
    download = "$HOME/Downloads";
    templates = "$HOME/Modelos";
    publicShare = "$HOME/Público";
    documents = "$HOME/Documentos";
    music = "$HOME/Músicas";
    pictures = "$HOME/Imagens";
    videos = "$HOME/Vídeos";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = "brave-browser.desktop";
        images = "imv.desktop";
        video = "mpv.desktop";
      in
      {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "application/pdf" = "org.pwmt.zathura.desktop";
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "image/png" = images;
        "image/jpeg" = images;
        "image/gif" = images;
        "image/webp" = images;
        "video/mp4" = video;
        "video/x-matroska" = video;
        "video/webm" = video;
        "audio/mpeg" = video;
        "audio/flac" = video;
      };
  };
}
