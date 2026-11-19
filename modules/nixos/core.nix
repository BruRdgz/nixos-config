{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [ "@wheel" ];
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
  };

  networking.networkmanager.enable = true;

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
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    file
    unzip
    pciutils
    usbutils
  ];
}
