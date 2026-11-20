# Aparência: GTK/Qt, ícones, cursor, wallpaper e as cores dos apps da sessão.
{ pkgs, ... }:
let
  p = import ./palette.nix;
  wallpaper = ./files/wallpapers/giyu.jpg;
  # mako/fuzzel aceitam cor com alfa em hex (RRGGBBAA).
  hex = c: builtins.substring 1 6 c;
in
{
  imports = [ ./waybar.nix ];

  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = p.font.mono;
      size = 11;
    };
  };
  # Apps libadwaita/GTK4 seguem a preferência de esquema escuro.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    enable = true;
    name = "Capitaine Cursors (Gruvbox)";
    package = pkgs.capitaine-cursors-themed;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  # Formato do hyprpaper 0.8+: um bloco por wallpaper; monitor vazio = todos.
  # O hyprpaper desenha frases aleatórias sobre o wallpaper por padrão.
  services.hyprpaper.settings.splash = false;
  services.hyprpaper.settings.wallpaper = [
    {
      monitor = "";
      path = "${wallpaper}";
      fit_mode = "cover";
    }
  ];

  programs.kitty = {
    font = {
      name = p.font.mono;
      size = 11;
    };
    settings = {
      background_opacity = "0.85";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;

      foreground = p.fg;
      background = p.bg0;
      selection_foreground = p.bg0;
      selection_background = p.fg4;
      cursor = p.fg;
      url_color = p.brightBlue;
      color0 = p.bg0;
      color8 = p.gray;
      color1 = p.red;
      color9 = p.brightRed;
      color2 = p.green;
      color10 = p.brightGreen;
      color3 = p.yellow;
      color11 = p.brightYellow;
      color4 = p.blue;
      color12 = p.brightBlue;
      color5 = p.purple;
      color13 = p.brightPurple;
      color6 = p.aqua;
      color14 = p.brightAqua;
      color7 = p.fg4;
      color15 = p.fg;
    };
  };

  programs.fuzzel.settings = {
    main = {
      font = "${p.font.mono}:size=12";
      icon-theme = "Papirus-Dark";
      terminal = "kitty";
      width = 40;
      horizontal-pad = 16;
      vertical-pad = 12;
    };
    colors = {
      background = "${hex p.bg1}f2";
      text = "${hex p.fg}ff";
      prompt = "${hex p.accent}ff";
      input = "${hex p.fg}ff";
      match = "${hex p.accent}ff";
      selection = "${hex p.bg3}ff";
      selection-text = "${hex p.fg}ff";
      selection-match = "${hex p.accent}ff";
      border = "${hex p.bg2}ff";
    };
    border = {
      width = 2;
      radius = 12;
    };
  };

  services.mako.settings = {
    font = "${p.font.mono} 11";
    background-color = p.bg0h;
    text-color = p.fg;
    border-color = p.bg2;
    border-radius = 10;
    border-size = 2;
    padding = "10";
    default-timeout = 5000;
    "urgency=critical" = {
      background-color = "#3c1f1e";
      border-color = p.brightRed;
      default-timeout = 0;
    };
  };

  programs.hyprlock.settings = {
    background = [
      {
        path = "${wallpaper}";
        blur_passes = 2;
      }
    ];
    input-field = [
      {
        size = "280, 50";
        outer_color = "rgb(${hex p.bg2})";
        inner_color = "rgb(${hex p.bg1})";
        font_color = "rgb(${hex p.fg})";
        check_color = "rgb(${hex p.accent})";
        fail_color = "rgb(${hex p.red})";
        placeholder_text = "senha";
        rounding = 12;
      }
    ];
  };

  home.packages = [ pkgs.fastfetch ];
}
