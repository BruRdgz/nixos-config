{ pkgs, ... }:
let
  p = import ../../home/palette.nix;
  hex = c: builtins.substring 1 6 c;
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # As 16 cores do console (TTYs e tuigreet) na paleta, na mesma ordem do kitty.
  console.colors = map hex [
    p.bg0
    p.red
    p.green
    p.yellow
    p.blue
    p.purple
    p.aqua
    p.fg4
    p.gray
    p.brightRed
    p.brightGreen
    p.brightYellow
    p.brightBlue
    p.brightPurple
    p.brightAqua
    p.fg
  ];

  services.greetd = {
    enable = true;
    # O tema do tuigreet usa os nomes ANSI, que o console.colors acima mapeia na paleta:
    # azul-lâmina na moldura e no prompt, carmim na hora, mostarda nos atalhos.
    settings.default_session.command = builtins.concatStringsSep " " [
      "${pkgs.tuigreet}/bin/tuigreet"
      "--time --time-format '%a, %d %b · %H:%M'"
      "--remember --asterisks"
      "--width 60 --window-padding 2 --container-padding 2"
      "--theme 'border=lightblue;title=lightblue;prompt=lightblue;input=white;text=white;time=lightred;greet=white;action=darkgray;button=yellow;container=black'"
      "--cmd 'uwsm start hyprland-uwsm.desktop'"
    ];
  };

  # O hyprlock (configurado no home-manager) autentica pelo PAM "hyprlock"; sem este
  # serviço ele cai no do `su` e a senha pode não destravar a tela.
  security.pam.services.hyprlock = { };

  # Keyring destravado pela senha do login (segredos de apps, tokens do gh etc.).
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.seahorse.enable = true;

  # O portal do Hyprland não tem seletor de arquivos; o GTK cobre isso.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Experimental: nível de bateria de fones/controles; FastConnectable: reconexão rápida.
    settings.General = {
      Experimental = true;
      FastConnectable = true;
    };
  };
  services.blueman.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  programs.dconf.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    maple-mono.NF-CN
    inter
    dejavu_fonts
    fira-code
    source-code-pro
  ];

  # Codecs para apps GStreamer (miniaturas de vídeo no Nautilus, players GNOME).
  environment.systemPackages = with pkgs.gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
}
