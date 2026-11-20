# Instalação no desktop

Roteiro para o dia da instalação. A ordem importa: a senha do usuário vem do sops
(`users.mutableUsers = false`), então a máquina precisa conseguir descriptografar
`secrets/secrets.yaml` **já no primeiro boot**. Se não conseguir, não há como logar.

## 0. Antes (ainda no Fedora / VM)

- [ ] **Guardar a chave age pessoal** (`~/.config/sops/age/keys.txt` da VM) no gerenciador
      de senhas. É ela que permite reeditar os segredos e adicionar a chave do desktop.
      Sem ela, e com a VM apagada, os segredos ficam presos.
- [ ] Preencher os valores do restic (`sops secrets/secrets.yaml`) e dar push.
- [ ] Gravar o ISO mínimo do NixOS (unstable) num pendrive.

## 1. Boot pelo ISO e preparo

```sh
sudo -i
nix-shell -p git gh sops age ssh-to-age
gh auth login                      # o repo é privado
git clone https://github.com/BruRdgz/nixos-config /root/nixos-config
cd /root/nixos-config
mkdir -p ~/.config/sops/age && $EDITOR ~/.config/sops/age/keys.txt   # colar a chave pessoal
```

## 2. Discos

```sh
ls -l /dev/disk/by-id/ | grep -v part
```

Trocar os placeholders em `hosts/desktop/disk-system.nix` e `disk-data.nix` pelos ids
(`nvme-...`, `ata-...`). Conferir duas vezes qual é qual: o passo 5 apaga os dois.

## 3. Hardware

```sh
nixos-generate-config --no-filesystems --show-hardware-config > /tmp/hw.nix
```

Levar para `hosts/desktop/hardware.nix` os módulos de initrd/kernel que ele detectar,
mantendo o que já está lá (amdgpu no initrd, microcode, regra do RTL8821CU).

## 4. Chave do host no sops

```sh
ssh-keygen -t ed25519 -N "" -C desktop -f /tmp/ssh_host_ed25519_key
ssh-to-age < /tmp/ssh_host_ed25519_key.pub
```

Em `.sops.yaml`, adicionar `- &desktop age1...` nas `keys` e `- *desktop` no
`key_groups`. Depois:

```sh
sops updatekeys secrets/secrets.yaml
sops -d secrets/secrets.yaml > /dev/null && echo ok   # confere que a chave pessoal abre
```

## 5. Particionar (destrutivo)

```sh
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#desktop
```

Pede a senha do LUKS de cada disco. Tudo montado em `/mnt`.

## 6. Instalar

```sh
mkdir -p /mnt/etc/ssh
cp /tmp/ssh_host_ed25519_key* /mnt/etc/ssh/
chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key

nixos-install --flake .#desktop --no-root-passwd
```

Repo e chave pessoal para o home (uid 1000, grupo `users`):

```sh
cp -r /root/nixos-config /mnt/home/seraphiine/nixos-config
mkdir -p /mnt/home/seraphiine/.config/sops/age
cp ~/.config/sops/age/keys.txt /mnt/home/seraphiine/.config/sops/age/
chmod 600 /mnt/home/seraphiine/.config/sops/age/keys.txt
chown -R 1000:100 /mnt/home/seraphiine
reboot
```

## 7. Depois do primeiro boot

- [ ] Commit e push das mudanças (discos, hardware, `.sops.yaml`).
- [ ] `sudo tailscale up`
- [ ] Backup: `sudo systemctl start restic-backups-home`, depois restaurar uma pasta
      qualquer com `restic restore` para provar que funciona.
- [ ] `rg 'TODO'`: sensor `k10temp` na barra (`grep . /sys/class/hwmon/*/name`), margens
      do wlogout para o monitor, `user.email` do git.
- [ ] Quando a VM for aposentada: tirar `&desktop-vm` do `.sops.yaml` e rodar
      `sops updatekeys` de novo.

## Se não conseguir logar

Quase sempre é o sops sem acesso à chave do host. Bootar o ISO, abrir os LUKS, montar e
conferir `/mnt/etc/ssh/ssh_host_ed25519_key` e se o `age1...` dela está no `.sops.yaml`
usado no `nixos-install`; corrigir e rodar `nixos-install` de novo.
