# Barra única, fina e translúcida (o blur vem de uma layer rule no Hyprland).
# Workspace ativo marcado por uma faixa amarela, como listra de corrida.
let
  p = import ./palette.nix;
in
{
  programs.waybar = {
    settings = [
      {
        layer = "top";
        height = 30;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "mpris"
          "pulseaudio"
          "hyprland/language"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
          persistent-workspaces."*" = 5;
        };

        clock = {
          format = "{:%a %d  %H:%M}";
          locale = "pt_BR.UTF-8";
          tooltip-format = "{:%A, %d de %B de %Y}";
        };

        mpris = {
          format = "{player_icon} {title} · {artist}";
          format-paused = "{status_icon} {title} · {artist}";
          player-icons.default = "󰝚";
          status-icons.paused = "󰏤";
          title-len = 40;
          artist-len = 25;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 mudo";
          format-icons = {
            headphone = "󰋋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-middle = "pavucontrol";
        };

        "hyprland/language" = {
          format-pt = "br";
          format-en = "us";
        };

        tray = {
          icon-size = 15;
          spacing = 8;
        };
      }
    ];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "${p.font.ui}", "${p.font.icons}";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: alpha(${p.bg0}, 0.75);
        color: ${p.fg};
      }

      #workspaces button {
        padding: 0 10px;
        color: ${p.muted};
        background: transparent;
        box-shadow: inset 0 -3px transparent;
      }

      #workspaces button.active {
        color: ${p.accent};
        box-shadow: inset 0 -3px ${p.accent};
      }

      #workspaces button.urgent {
        color: ${p.alert};
      }

      #workspaces button:hover {
        background: ${p.bg2};
        color: ${p.fg};
      }

      #clock {
        font-weight: 600;
      }

      #mpris,
      #pulseaudio,
      #language,
      #tray {
        padding: 0 10px;
        color: ${p.fgDim};
      }

      #mpris.playing {
        color: ${p.fg};
      }

      #pulseaudio.muted {
        color: ${p.alert};
      }

      #language {
        color: ${p.accent};
        font-weight: 600;
      }
    '';
  };
}
