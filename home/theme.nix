# Aparência: GTK/Qt, ícones, cursor, wallpaper e as cores dos apps da sessão.
{ pkgs, ... }:
let
  p = import ./palette.nix;
  wallpaper = ./files/wallpapers/giyu.jpg;
  # fuzzel aceita cor com alfa em hex (RRGGBBAA).
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
      name = p.font.sans;
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
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
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
    keybindings = {
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+t" = "new_tab_with_cwd";
    };
    settings = {
      background_opacity = "0.85";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      cursor_shape = "beam";
      cursor_blink_interval = 0;
      scrollback_lines = 10000;
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      url_style = "curly";
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

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
      # Maple Mono como reserva para glifos que a Inter não tem.
      font = "${p.font.sans}:size=12,${p.font.mono}:size=12";
      prompt = "'›  '";
      lines = 10;
      inner-pad = 6;
      icon-theme = "Papirus-Dark";
      terminal = "kitty";
      width = 40;
      horizontal-pad = 16;
      vertical-pad = 12;
    };
    colors = {
      background = "${hex p.bg1}d9";
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

  # Inspirado na tela de bloqueio do GNOME: relógio grande com a data embaixo no alto,
  # usuário e senha embaixo, sobre o wallpaper desfocado e escurecido.
  programs.hyprlock.settings = {
    general.hide_cursor = true;
    background = [
      {
        path = "${wallpaper}";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.55;
      }
    ];
    label = [
      # Relógio
      {
        text = "$TIME";
        font_family = "${p.font.mono} Light";
        font_size = 104;
        color = "rgb(${hex p.fg0})";
        position = "0, 210";
        halign = "center";
        valign = "center";
      }
      # Data por extenso ("sexta-feira, 20 de novembro"), atualizada a cada minuto.
      {
        text = ''cmd[update:60000] LC_TIME=pt_BR.UTF-8 date +"%A, %-d de %B"'';
        font_family = p.font.mono;
        font_size = 20;
        color = "rgb(${hex p.fg})";
        position = "0, 110";
        halign = "center";
        valign = "center";
      }
      # Usuário acima do campo
      {
        text = "  $USER";
        font_family = p.font.mono;
        font_size = 16;
        color = "rgb(${hex p.accent})";
        position = "0, -150";
        halign = "center";
        valign = "center";
      }
      # Layout de teclado ativo, para não errar a senha por estar em "us".
      {
        text = "󰌌  $LAYOUT";
        font_family = p.font.mono;
        font_size = 12;
        color = "rgb(${hex p.fg4})";
        position = "0, -265";
        halign = "center";
        valign = "center";
      }
    ];
    input-field = [
      {
        size = "320, 48";
        position = "0, -210";
        halign = "center";
        valign = "center";
        # Sempre visível, como no GNOME (o padrão some quando está vazio).
        fade_on_empty = false;
        rounding = -1;
        outline_thickness = 2;
        outer_color = "rgba(${hex p.bg3}cc)";
        inner_color = "rgba(${hex p.bg1}cc)";
        font_color = "rgb(${hex p.fg})";
        font_family = p.font.mono;
        check_color = "rgb(${hex p.accent})";
        fail_color = "rgb(${hex p.brightRed})";
        fail_text = "senha incorreta";
        placeholder_text = "<i>digite a senha…</i>";
        dots_size = 0.25;
        dots_spacing = 0.35;
      }
    ];
  };

  home.packages = [ pkgs.fastfetch ];
}
