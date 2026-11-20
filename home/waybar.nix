# Barra em "pílulas" flutuantes. Esquerda: lançador, workspaces e janela ativa.
# Centro: mídia. Direita: sistema, status, bandeja, relógio, notificações e energia.
let
  p = import ./palette.nix;
in
{
  programs.waybar = {
    settings = [
      {
        layer = "top";
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
          format = "{player_icon} {title} · {artist}";
          format-paused = "{status_icon} {title} · {artist}";
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
        border-radius: 13px;
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
      }

      /* Cada grupo é uma pílula própria. */
      #launcher,
      #window,
      #mpris,
      #system,
      #status,
      #tray,
      #clock,
      #custom-notification,
      #custom-power {
        background: ${p.bg1};
        padding: 1px 10px;
        margin: 5px 3px 0 3px;
      }

      #custom-logo {
        font-size: 20px;
        color: ${p.brightRed};
        padding: 0 12px 0 2px;
      }

      #workspaces button {
        padding: 0 6px;
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

      /* Sem janela aberta, a pílula do título some. */
      window#waybar.empty #window {
        background: transparent;
        padding: 0;
        margin: 0;
      }

      #mpris {
        color: ${p.fg};
        padding: 1px 14px;
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
