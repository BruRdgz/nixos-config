# Programas que esperam um Linux FHS, em três camadas:
#  1. nix-ld + envfs: transparente para binários pré-compilados e shebangs como /bin/bash.
#  2. `fhs`: shell com /usr/lib etc. de verdade, para instaladores e toolchains de fabricante.
#  3. distrobox: para o que precisa de uma distro inteira.
{ pkgs, ... }:
let
  # A lista de bibliotecas que o nixpkgs mantém para AppImages: cobre GUI, áudio e rede.
  fhsArgs = pkgs.appimageTools.defaultFhsEnvArgs;
in
{
  programs.nix-ld = {
    enable = true;
    libraries = fhsArgs.multiPkgs pkgs ++ fhsArgs.targetPkgs pkgs;
  };
  services.envfs.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = [
    (pkgs.buildFHSEnv (
      fhsArgs
      // {
        name = "fhs";
        runScript = "zsh";
      }
    ))
    pkgs.distrobox
  ];
}
