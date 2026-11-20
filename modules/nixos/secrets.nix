# sops-nix: os segredos ficam criptografados em secrets/secrets.yaml e são
# descriptografados para /run/secrets na ativação, nunca no /nix/store.
# A máquina usa a chave SSH do host; editar: `sops secrets/secrets.yaml`.
{ config, lib, pkgs, ... }:
{
  # Fechado na interface pública; acessível pela Tailscale (interface confiável).
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = lib.mkDefault "no";
      AllowUsers = lib.mkDefault [ "seraphiine" ];
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # Precisa existir antes da criação dos usuários.
    secrets.user-password.neededForUsers = true;
  };

  # Usuários declarativos: a senha vem do sops e `passwd` não persiste entre rebuilds.
  users.mutableUsers = false;
  users.users.seraphiine.hashedPasswordFile = config.sops.secrets.user-password.path;

  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];
}
