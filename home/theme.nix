# Aparência: GTK/Qt, ícones, cursor, wallpaper e as cores dos apps da sessão.
{ pkgs, ... }:
let
  p = import ./palette.nix;
  wallpaper = ./files/wallpapers/pista.png;
  # "#rrggbb" -> "rrggbb", para formatos que querem hex sem "#" (fuzzel, hyprlock).
  hex = c: builtins.substring 1 6 c;
in
{
  imports = [ ./waybar.nix ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "yellow"; };
    };
    font = {
      name = p.font.ui;
      size = 11;
    };
  };
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    accent-color = "yellow";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  # Formato do hyprpaper 0.8+: um bloco por wallpaper; monitor vazio = todos.
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
    settings = with p.ansi; {
      background_opacity = "0.9";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;

      foreground = p.fg;
      background = p.bg0;
      selection_foreground = p.bg0;
      selection_background = p.accent;
      cursor = p.accent;
      cursor_text_color = p.bg0;
      url_color = p.teal;
      active_tab_foreground = p.bg0;
      active_tab_background = p.accent;
      inactive_tab_foreground = p.fgDim;
      inactive_tab_background = p.bg1;

      color0 = black;
      color8 = brightBlack;
      color1 = red;
      color9 = brightRed;
      color2 = green;
      color10 = brightGreen;
      color3 = yellow;
      color11 = brightYellow;
      color4 = blue;
      color12 = brightBlue;
      color5 = magenta;
      color13 = brightMagenta;
      color6 = cyan;
      color14 = brightCyan;
      color7 = white;
      color15 = brightWhite;
    };
  };

  programs.fuzzel.settings = {
    main = {
      font = "${p.font.ui}:size=12";
      icon-theme = "Papirus-Dark";
      terminal = "kitty";
      width = 40;
      horizontal-pad = 16;
      vertical-pad = 12;
    };
    colors = {
      background = "${hex p.bg0}f0";
      text = "${hex p.fg}ff";
      prompt = "${hex p.accent}ff";
      input = "${hex p.fg}ff";
      match = "${hex p.accent}ff";
      selection = "${hex p.bg2}ff";
      selection-text = "${hex p.fg}ff";
      selection-match = "${hex p.accent}ff";
      border = "${hex p.accent}ff";
    };
    border = {
      width = 2;
      radius = 4;
    };
  };

  services.mako.settings = {
    font = "${p.font.ui} 11";
    background-color = p.bg0;
    text-color = p.fg;
    border-color = p.bg3;
    border-radius = 4;
    border-size = 2;
    padding = "10";
    default-timeout = 5000;
    "urgency=critical" = {
      border-color = p.alert;
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
    label = [
      {
        text = "$TIME";
        font_family = p.font.ui;
        font_size = 72;
        color = "rgb(${hex p.fg})";
        position = "0, 120";
        halign = "center";
        valign = "center";
      }
    ];
    input-field = [
      {
        size = "280, 50";
        outer_color = "rgb(${hex p.accent})";
        inner_color = "rgb(${hex p.bg0})";
        font_color = "rgb(${hex p.fg})";
        check_color = "rgb(${hex p.teal})";
        fail_color = "rgb(${hex p.alert})";
        placeholder_text = "senha";
        rounding = 4;
      }
    ];
  };

  home.packages = [ pkgs.fastfetch ];
}
