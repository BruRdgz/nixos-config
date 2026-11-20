{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [ "@wheel" ];
    warn-dirty = false;
    # Mantém as dependências dos devShells do direnv vivas entre coletas de lixo.
    keep-outputs = true;
    keep-derivations = true;
  };
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    loader.efi.canTouchEfiVariables = true;
    # Kernel recente para hardware AMD novo.
    kernelPackages = pkgs.linuxPackages_latest;

    # Boot silencioso com splash; o Plymouth também pede a senha do LUKS.
    plymouth.enable = true;
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
      "rd.udev.log_level=3"
    ];

    # O padrão (8192) estoura em projetos grandes de Node/Rust/Scala vigiados por LSPs.
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 512;
    };
  };

  networking.networkmanager.enable = true;
  # Desktop: não segurar o boot esperando a rede.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Tailscale como cliente; o SSH só é alcançável por ela (ver secrets.nix).
  # Primeiro login: `sudo tailscale up`.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
  services.printing.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "br-abnt2";

  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.btrfs.autoScrub.enable = true;

  # Rebuild mais legível; o `nh clean` substitui o nix.gc.
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 10";
    };
  };
  programs.nix-index-database.comma.enable = true;

  programs.zsh.enable = true;
  users.users.seraphiine = {
    isNormalUser = true;
    shell = pkgs.zsh;
    homeMode = "700";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    file
    unzip
    p7zip
    ouch
    rsync
    jq
    ripgrep
    fd
    tree
    # Diagnóstico
    lsof
    strace
    pciutils
    usbutils
    smartmontools
    dig
    mtr
    nmap
    # Nix
    nix-output-monitor
    nix-tree
  ];
}
