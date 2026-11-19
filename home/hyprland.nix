{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # O UWSM (habilitado no sistema) já cuida da sessão systemd.
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "fuzzel";

      monitor = [ ",preferred,auto,1" ];

      input = {
        kb_layout = "br,us";
        # custom:scroll_led_numlock: o backlight do teclado (LED do Scroll Lock) segue o Num Lock.
        kb_options = "grp:win_space_toggle,custom:scroll_led_numlock";
        numlock_by_default = true;
        follow_mouse = 1;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      decoration.rounding = 6;

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $menu"
        "$mod, Q, killactive"
        "$mod SHIFT, E, exec, uwsm stop"
        "$mod, L, exec, loginctl lock-session"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ]
      ++ builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = toString (i + 1);
            key = toString (if i == 9 then 0 else i + 1);
          in
          [
            "$mod, ${key}, workspace, ${ws}"
            "$mod SHIFT, ${key}, movetoworkspace, ${ws}"
          ]
        ) 10
      );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
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
  services.mako.enable = true;
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
    pavucontrol
    nautilus
  ];
}
