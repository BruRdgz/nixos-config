# Aparência: GTK/Qt, ícones, cursor, wallpaper e as cores dos apps da sessão.
{ pkgs, ... }:
let
  p = import ./palette.nix;
  wallpaper = ./files/wallpapers/giyu.jpg;
  # mako/fuzzel aceitam cor com alfa em hex (RRGGBBAA).
  hex = c: builtins.substring 1 6 c;

  # Cores nomeadas do libadwaita, que o adw-gtk3 (GTK 3) também respeita: é assim
  # que os dois toolkits recebem a nossa paleta sem um tema GTK próprio.
  shade = "rgba(0, 0, 0, 0.36)";
  adwaitaColors = ''
    @define-color accent_color ${p.accent};
    @define-color accent_bg_color ${p.blue};
    @define-color accent_fg_color ${p.fg0};
    @define-color destructive_color ${p.brightRed};
    @define-color destructive_bg_color ${p.red};
    @define-color destructive_fg_color ${p.fg0};
    @define-color success_color ${p.brightGreen};
    @define-color success_bg_color ${p.green};
    @define-color success_fg_color ${p.fg0};
    @define-color warning_color ${p.brightYellow};
    @define-color warning_bg_color ${p.yellow};
    @define-color warning_fg_color ${p.bg0h};
    @define-color error_color ${p.brightRed};
    @define-color error_bg_color ${p.red};
    @define-color error_fg_color ${p.fg0};

    @define-color window_bg_color ${p.bg0};
    @define-color window_fg_color ${p.fg};
    @define-color view_bg_color ${p.bg0h};
    @define-color view_fg_color ${p.fg};
    @define-color headerbar_bg_color ${p.bg1};
    @define-color headerbar_fg_color ${p.fg};
    @define-color headerbar_border_color ${p.fg};
    @define-color headerbar_backdrop_color ${p.bg0};
    @define-color headerbar_shade_color ${shade};
    @define-color sidebar_bg_color ${p.bg1};
    @define-color sidebar_fg_color ${p.fg};
    @define-color sidebar_backdrop_color ${p.bg0};
    @define-color sidebar_shade_color ${shade};
    @define-color card_bg_color ${p.bg1};
    @define-color card_fg_color ${p.fg};
    @define-color card_shade_color ${shade};
    @define-color dialog_bg_color ${p.bg1};
    @define-color dialog_fg_color ${p.fg};
    @define-color popover_bg_color ${p.bg1};
    @define-color popover_fg_color ${p.fg};
    @define-color thumbnail_bg_color ${p.bg1};
    @define-color thumbnail_fg_color ${p.fg};
    @define-color shade_color ${shade};
    @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
  '';
in
{
  imports = [ ./waybar.nix ];

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    gtk3.extraCss = adwaitaColors;
    # O GTK 4 já usa o libadwaita; não importar um tema, só as cores.
    gtk4.theme = null;
    gtk4.extraCss = adwaitaColors;
    iconTheme = {
      name = "Papirus-Dark";
      # Pastas no azul da lâmina, o destaque da paleta.
      package = pkgs.papirus-icon-theme.override { color = "blue"; };
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
