# sops-nix: os segredos ficam criptografados no repo e são descriptografados para
# /run/secrets na ativação, nunca no /nix/store. A máquina usa a chave SSH do host.
# Os segredos (e o backup restic, que depende deles) entram quando a chave age
# pessoal e o .sops.yaml existirem.
{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings.PasswordAuthentication = false;
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
