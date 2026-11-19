{ pkgs, ... }:
let
  p = import ./palette.nix;
  # Cores que o hyprland.lua usa, no formato de cor do Hyprland ("rgb(rrggbb)").
  rgb = c: "rgb(${builtins.substring 1 6 c})";
  luaPalette = ''
    local palette = {
      accent = "${rgb p.accent}",
      bg3    = "${rgb p.bg3}",
    }
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # O UWSM (habilitado no sistema) já cuida da sessão systemd.
    systemd.enable = false;
    # Config em Lua (formato atual do Hyprland), escrita à mão: mais legível que gerar Lua a partir de Nix.
    configType = "lua";
    extraConfig = luaPalette + builtins.readFile ./files/hypr/hyprland.lua;
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
    playerctl
    pavucontrol
    nautilus
  ];
}
