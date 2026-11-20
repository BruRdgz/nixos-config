# Barra em "pílulas" flutuantes: workspaces em kana à esquerda, mídia no centro,
# áudio/layout/bandeja/relógio à direita.
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
          "custom/logo"
          "hyprland/workspaces"
        ];
        modules-center = [ "mpris" ];
        modules-right = [
          "pulseaudio"
          "hyprland/language"
          "tray"
          "clock"
        ];

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

        mpris = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "{status_icon} {title} - {artist}";
          player-icons.default = "󰝚";
          status-icons.paused = "󰏤";
          title-len = 40;
          artist-len = 25;
        };

        pulseaudio = {
          format = "{icon} {volume}%  {format_source}";
          format-muted = "󰖁  {format_source}";
          format-source = "󰍬";
          format-source-muted = "󰍭";
          format-icons = {
            headphone = "󰋋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-click-middle = "pavucontrol";
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
          tooltip-format = "{:%A, %d de %B de %Y}";
        };
      }
    ];

    style = ''
      * {
        border: none;
        border-radius: 13px;
        font-family: "${p.font.mono}", "${p.font.icons}", "Noto Sans CJK JP";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: ${p.fg};
      }

      .modules-left,
      .modules-right,
      #mpris {
        background: ${p.bg1};
        padding: 1px 8px;
        margin: 5px 4px 0 4px;
      }

      #custom-logo {
        font-size: 20px;
        color: ${p.brightRed};
        padding: 0 14px 0 4px;
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

      #workspaces button:hover {
        color: ${p.brightRed};
        box-shadow: none;
        text-shadow: none;
      }

      /* A pílula do centro é o próprio módulo, para sumir quando nada toca. */
      #mpris {
        color: ${p.fg};
        padding: 1px 12px;
      }

      #mpris.paused {
        color: ${p.fg4};
      }

      #pulseaudio,
      #language,
      #tray,
      #clock {
        padding: 0 10px;
      }

      #pulseaudio.muted {
        color: ${p.red};
      }

      #clock {
        font-weight: bold;
      }
    '';
  };
}
