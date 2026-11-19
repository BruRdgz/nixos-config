# Backup diário do home com restic para o Backblaze B2. Repositório, senha e
# credenciais vêm do sops (restic/repository, restic/password, restic/env).
{ config, ... }:
let
  s = config.sops.secrets;
in
{
  sops.secrets = {
    "restic/repository" = { };
    "restic/password" = { };
    # Formato de environment file: B2_ACCOUNT_ID=... e B2_ACCOUNT_KEY=...
    "restic/env" = { };
  };

  services.restic.backups.home = {
    initialize = true;
    repositoryFile = s."restic/repository".path;
    passwordFile = s."restic/password".path;
    environmentFile = s."restic/env".path;
    paths = [ "/home/seraphiine" ];
    exclude = [
      "/home/*/.cache"
      "/home/*/.local/share/Steam"
      "/home/*/.local/share/containers"
      "/home/*/.local/share/flatpak"
      "/home/*/.local/share/Trash"
      "/home/*/.cargo/registry"
      "/home/*/.rustup"
      "/home/*/.npm"
      "**/target"
      "**/node_modules"
      "**/.venv"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}
