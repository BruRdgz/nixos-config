# Widgets da sessão: central de notificações/controle (swaync, Super+N ou o sino da
# barra) e menu de energia em tela cheia (wlogout, Super+Esc ou o botão da barra).
{ pkgs, ... }:
let
  p = import ./palette.nix;
  # Os ícones do wlogout vêm roxos; recolore para o texto da paleta (mantendo o alfa).
  wlogoutIcons =
    pkgs.runCommand "wlogout-icons-palette" { nativeBuildInputs = [ pkgs.imagemagick ]; }
      ''
        mkdir -p $out
        for f in ${pkgs.wlogout}/share/wlogout/icons/*.png; do
          magick "$f" -fill "${p.fg}" -colorize 100 "$out/$(basename "$f")"
        done
      '';
  # Os 5 botões numa linha só (o padrão é 3 por linha, deixando uma vaga vazia), com
  # margens de janela em px. TODO(hardware): ajustar -T/-B/-L/-R ao monitor real.
  powerMenu = "wlogout -b 5 -T 260 -B 260 -L 120 -R 120";
in
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      control-center-width = 400;
      control-center-margin-top = 8;
      control-center-margin-right = 8;
      control-center-margin-bottom = 8;
      notification-window-width = 380;
      timeout = 6;
      timeout-low = 4;
      fit-to-screen = true;
      widgets = [
        "title"
        "dnd"
        "mpris"
        "volume"
        "buttons-grid"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notificações";
          clear-all-button = true;
          button-text = "Limpar";
        };
        dnd.text = "Não perturbe";
        mpris = {
          image-size = 72;
          image-radius = 10;
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
        };
        buttons-grid.actions = [
          {
            label = "󰌾";
            command = "loginctl lock-session";
          }
          {
            label = "󰹑";
            command = "sh -c 'swaync-client -cp; sleep 0.4; grim -g \"$(slurp)\" - | wl-copy'";
          }
          {
            label = "󰕾";
            command = "pavucontrol";
          }
          {
            label = "󰂯";
            command = "blueman-manager";
          }
          {
            label = "󰀻";
            command = "fuzzel";
          }
          {
            label = "󰐥";
            command = "sh -c 'swaync-client -cp; ${powerMenu}'";
          }
        ];
      };
    };
    style = ''
      * {
        font-family: "${p.font.mono}";
        font-size: 14px;
      }

      .control-center {
        background: alpha(${p.bg0}, 0.92);
        border: 2px solid ${p.bg2};
        border-radius: 14px;
        color: ${p.fg};
        padding: 8px;
      }

      .notification-row { outline: none; }

      .notification,
      .notification-default-action,
      .floating-notifications .notification {
        background: ${p.bg1};
        color: ${p.fg};
        border-radius: 12px;
      }

      .notification { border: 1px solid ${p.bg2}; }
      .notification.critical { border-color: ${p.brightRed}; }

      .notification-default-action:hover { background: ${p.bg2}; }

      .summary { color: ${p.fg0}; font-weight: bold; }
      .body, .time { color: ${p.fg4}; }

      .close-button {
        background: ${p.bg2};
        color: ${p.fg};
        border-radius: 99px;
      }
      .close-button:hover { background: ${p.red}; }

      .widget-title {
        color: ${p.fg0};
        font-size: 16px;
        font-weight: bold;
        margin: 6px 8px;
      }
      .widget-title > button {
        background: ${p.bg2};
        color: ${p.fg};
        border-radius: 10px;
        padding: 2px 12px;
      }
      .widget-title > button:hover { background: ${p.red}; }

      .widget-dnd { margin: 6px 8px; color: ${p.fg}; }
      .widget-dnd > switch { background: ${p.bg2}; border-radius: 99px; }
      .widget-dnd > switch:checked { background: ${p.blue}; }
      .widget-dnd > switch slider { background: ${p.fg}; border-radius: 99px; }

      .widget-mpris > box > button,
      .widget-mpris-player {
        background: ${p.bg1};
        border-radius: 12px;
        margin: 6px 8px;
        padding: 8px;
      }
      .widget-mpris-title { color: ${p.fg0}; font-weight: bold; }
      .widget-mpris-subtitle { color: ${p.fg4}; }

      .widget-volume {
        background: ${p.bg1};
        border-radius: 12px;
        margin: 6px 8px;
        padding: 6px 10px;
      }
      .widget-volume trough { background: ${p.bg2}; border-radius: 99px; min-height: 6px; }
      .widget-volume highlight { background: ${p.accent}; border-radius: 99px; }

      .widget-buttons-grid {
        background: ${p.bg1};
        border-radius: 12px;
        margin: 6px 8px;
        padding: 6px;
      }
      .widget-buttons-grid > flowbox > flowboxchild > button {
        background: ${p.bg2};
        color: ${p.fg};
        border-radius: 10px;
        min-height: 42px;
        font-size: 18px;
      }
      .widget-buttons-grid > flowbox > flowboxchild > button:hover {
        background: ${p.blue};
        color: ${p.fg0};
      }
    '';
  };

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "loginctl lock-session";
        text = "Bloquear";
        keybind = "l";
      }
      {
        label = "logout";
        action = "uwsm stop";
        text = "Sair";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspender";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reiniciar";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Desligar";
        keybind = "s";
      }
    ];
    style = ''
      * {
        font-family: "${p.font.mono}";
        background-image: none;
        box-shadow: none;
      }

      window {
        background-color: alpha(${p.bg0h}, 0.80);
      }

      button {
        color: ${p.fg};
        background-color: alpha(${p.bg1}, 0.90);
        border: 2px solid ${p.bg2};
        border-radius: 18px;
        margin: 10px;
        background-repeat: no-repeat;
        background-position: center 38%;
        background-size: 34%;
        font-size: 16px;
        transition: all 0.2s ease-in-out;
      }

      button:focus,
      button:hover {
        background-color: ${p.bg2};
        border-color: ${p.accent};
        color: ${p.accent};
      }

      #shutdown:hover, #shutdown:focus,
      #reboot:hover, #reboot:focus {
        border-color: ${p.brightRed};
        color: ${p.brightRed};
      }

      #lock { background-image: image(url("${wlogoutIcons}/lock.png")); }
      #logout { background-image: image(url("${wlogoutIcons}/logout.png")); }
      #suspend { background-image: image(url("${wlogoutIcons}/suspend.png")); }
      #reboot { background-image: image(url("${wlogoutIcons}/reboot.png")); }
      #shutdown { background-image: image(url("${wlogoutIcons}/shutdown.png")); }
    '';
  };
}
