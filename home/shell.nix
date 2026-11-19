{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 50000;
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./files/starship.toml);
  };

  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.btop.enable = true;
  # O thefuck saiu do nixpkgs; o pay-respects é o sucessor compatível.
  programs.pay-respects.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # O tmux.conf é o mesmo do Fedora; o tpm se instala sozinho no primeiro uso.
  home.packages = [ pkgs.tmux ];
  xdg.configFile."tmux/tmux.conf".text =
    builtins.replaceStrings [ "/bin/zsh" ] [ "${pkgs.zsh}/bin/zsh" ]
      (builtins.readFile ./files/tmux/tmux.conf);
}
