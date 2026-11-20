# Barra em blocos que "pendem" do topo da tela, com bordas curvas tipo aba de navegador.
# Esquerda: lançador, workspaces e janela ativa. Centro: mídia. Direita: sistema,
# status, bandeja, relógio, notificações e energia.
{ pkgs, ... }:
let
  p = import ./palette.nix;

  barHeight = 32;
  # Largura da curva que liga um bloco ao topo da tela.
  earWidth = 26;
  # O CSS do GTK não tem canto côncavo: a curva (um "S" que sai horizontal no topo e
  # chega horizontal embaixo) é um SVG na cor do bloco, desenhado sobre a borda lateral.
  ear =
    side:
    let
      path = if side == "right" then "M0 0 H26 C13 0 13 32 0 32 Z" else "M26 0 H0 C13 0 13 32 26 32 Z";
    in
    pkgs.writeText "waybar-ear-${side}.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" width="26" height="32" viewBox="0 0 26 32" preserveAspectRatio="none">
        <path d="${path}" fill="${p.bg1}"/>
      </svg>
    '';
  # Bloco com a curva de um lado: a cor de fundo fica no padding-box e a curva ocupa
  # a borda (transparente) daquele lado.
  withEar = side: ''
    background-color: transparent;
    border-${side}: ${toString earWidth}px solid transparent;
    background-image: linear-gradient(${p.bg1}, ${p.bg1}), url("${ear side}");
    background-clip: padding-box, border-box;
    background-origin: padding-box, border-box;
    background-position: center, ${side};
    background-size: auto, ${toString earWidth}px 100%;
    background-repeat: no-repeat;
  '';
in
{
  programs.waybar = {
    settings = [
      {
        layer = "top";
        height = barHeight;
        spacing = 0;

        modules-left = [
          "group/launcher"
          "hyprland/window"
        ];
        modules-center = [ "mpris" ];
        modules-right = [
          "group/system"
          "group/status"
          "tray"
          "clock"
          "custom/notification"
          "custom/power"
        ];

        "group/launcher" = {
          orientation = "horizontal";
          modules = [
            "custom/logo"
            "hyprland/workspaces"
          ];
        };

        "custom/logo" = {
          format = "";
          tooltip = false;
          on-click = "fuzzel";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          persistent-workspaces."*" = 6;
          format-icons = {
            "1" = "み";
            "2" = "ん";
            "3" = "な";
            "4" = "で";
            "5" = "レ";
            "6" = "イ";
            "7" = "ン";
            "8" = "を";
            "9" = "愛";
            "10" = "そ";
          };
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 45;
          separate-outputs = true;
        };

        mpris = {
          # {dynamic} junta só os campos presentes (sem "·" solto quando falta artista).
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} {dynamic}";
          dynamic-order = [
            "title"
            "artist"
          ];
          dynamic-separator = " · ";
          player-icons.default = "󰝚";
          status-icons.paused = "󰏤";
          title-len = 35;
          artist-len = 20;
          tooltip-format = "{player}: {title} — {artist} ({album})\nclique: tocar/pausar · direito: próxima · meio: anterior";
          on-click = "playerctl play-pause";
          on-click-right = "playerctl next";
          on-click-middle = "playerctl previous";
        };

        "group/system" = {
          orientation = "horizontal";
          modules = [
            "cpu"
            "memory"
            "temperature"
          ];
        };

        cpu = {
          format = "󰻠 {usage}%";
          interval = 3;
          on-click = "kitty -e btop";
        };

        memory = {
          format = "󰍛 {percentage}%";
          interval = 5;
          tooltip-format = "{used:0.1f} / {total:0.1f} GiB em uso";
          on-click = "kitty -e btop";
        };

        # TODO(hardware): no Ryzen do desktop, apontar para o k10temp
        # (hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon"; input-filename = "temp1_input").
        temperature = {
          format = "󰔏 {temperatureC}°";
          critical-threshold = 85;
          interval = 5;
        };

        "group/status" = {
          orientation = "horizontal";
          modules = [
            "network"
            "bluetooth"
            "pulseaudio"
            "hyprland/language"
          ];
        };

        network = {
          format-ethernet = "󰈀";
          format-wifi = "󰖩";
          format-disconnected = "󰌘";
          tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%): {ipaddr}/{cidr}";
          tooltip-format-disconnected = "Sem conexão";
          on-click = "kitty -e nmtui";
        };

        bluetooth = {
          format = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connections}";
          # Sem adaptador (como na VM), o módulo some.
          format-no-controller = "";
          tooltip-format-connected = "{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          on-click = "blueman-manager";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁";
          format-icons = {
            headphone = "󰋋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
        };

        "hyprland/language" = {
          format-pt = "br";
          format-en = "us";
        };

        tray = {
          icon-size = 16;
          spacing = 10;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%a, %d %b  %H:%M}";
          locale = "pt_BR.UTF-8";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            format.today = "<span color='${p.accent}'><b>{}</b></span>";
          };
        };

        # Central de notificações (swaync): clique abre o painel, direito alterna "não perturbe".
        "custom/notification" = {
          format = "{icon}";
          format-icons = {
            notification = "󱅫";
            none = "󰂚";
            dnd-notification = "󰂛";
            dnd-none = "󰂛";
            inhibited-notification = "󱅫";
            inhibited-none = "󰂚";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰂛";
          };
          return-type = "json";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
          tooltip = false;
        };

        "custom/power" = {
          format = "󰐥";
          tooltip = false;
          on-click = "wlogout -b 5 -T 260 -B 260 -L 120 -R 120";
        };
      }
    ];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "${p.font.mono}";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: ${p.fg};
      }

      tooltip {
        background: ${p.bg0};
        border: 1px solid ${p.bg3};
        border-radius: 10px;
      }

      /* Módulos vizinhos com o mesmo fundo formam um bloco contínuo. */
      #launcher,
      #window,
      #mpris,
      #system,
      #status,
      #tray,
      #clock,
      #custom-notification,
      #custom-power {
        background-color: ${p.bg1};
        padding: 0 10px;
        margin: 0;
      }

      /* Bloco da esquerda: a curva fica no último módulo visível. */
      #window { ${withEar "right"} }
      window#waybar.empty #launcher { ${withEar "right"} }

      /* Centro: curva dos dois lados (some junto com o mpris quando nada toca). */
      #mpris {
        background-color: transparent;
        border-left: ${toString earWidth}px solid transparent;
        border-right: ${toString earWidth}px solid transparent;
        background-image: linear-gradient(${p.bg1}, ${p.bg1}), url("${ear "left"}"), url("${ear "right"}");
        background-clip: padding-box, border-box, border-box;
        background-origin: padding-box, border-box, border-box;
        background-position: center, left, right;
        background-size: auto, ${toString earWidth}px 100%, ${toString earWidth}px 100%;
        background-repeat: no-repeat;
      }

      /* Bloco da direita começa com a curva à esquerda. */
      #system { ${withEar "left"} }

      #custom-logo {
        font-size: 20px;
        color: ${p.brightRed};
        padding: 0 12px 0 2px;
      }

      #workspaces button {
        padding: 0 6px;
        margin: 4px 1px;
        border-radius: 10px;
        background: transparent;
        color: ${p.fg4};
        transition: all 0.3s ease-in-out;
      }

      #workspaces button.active {
        background: ${p.bg2};
        color: ${p.accent};
        min-width: 34px;
      }

      #workspaces button.urgent {
        color: ${p.brightRed};
      }

      #workspaces button:hover {
        color: ${p.brightRed};
        box-shadow: none;
        text-shadow: none;
      }

      #window {
        color: ${p.fg4};
      }

      /* Sem janela aberta, o título some (e a curva passa para o lançador). */
      window#waybar.empty #window {
        background: none;
        border: none;
        padding: 0;
      }

      #mpris {
        color: ${p.fg};
        padding: 0 8px;
      }

      #mpris.paused {
        color: ${p.fg4};
      }

      #cpu,
      #memory,
      #temperature,
      #network,
      #bluetooth,
      #pulseaudio,
      #language {
        padding: 0 7px;
      }

      #cpu { color: ${p.brightYellow}; }
      #memory { color: ${p.brightGreen}; }
      #temperature { color: ${p.brightAqua}; }
      #temperature.critical { color: ${p.brightRed}; }

      #network.disconnected,
      #pulseaudio.muted {
        color: ${p.brightRed};
      }

      #bluetooth.connected {
        color: ${p.accent};
      }

      #language {
        color: ${p.accent};
      }

      #clock {
        font-weight: bold;
      }

      #custom-notification {
        color: ${p.fg};
      }

      #custom-power {
        color: ${p.brightRed};
        padding: 1px 12px 1px 10px;
      }

      #custom-power:hover,
      #custom-notification:hover,
      #custom-logo:hover {
        background: ${p.bg2};
      }
    '';
  };
}
