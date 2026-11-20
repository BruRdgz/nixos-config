{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 50000;
      save = 50000;
      share = true;
      ignoreDups = true;
      # Comando começando com espaço não vai pro histórico (bom para segredos).
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    # Completação do zsh pelo fzf (Tab abre um seletor com prévia).
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    shellAliases = {
      rebuild = "nh os switch";
      nd = "nix develop";

      cd = "z";
      ".." = "cd ..";
      "..." = "cd ../..";

      v = "hx";
      g = "git";
      lg = "lazygit";
      c = "clear";

      ls = "eza --icons=auto";
      ll = "eza -lah --icons=auto --git";
      lt = "eza --tree --icons=auto";
      cat = "bat --paging=never";
      df = "duf";
      du = "dust";
    };

    # Cada terminal novo entra na mesma sessão "default" do tmux (fora de IDEs).
    initContent = ''
      if [[ -o interactive && -t 0 && -t 1 && -z "$TMUX" && -z "$VSCODE_INJECTION" && -z "$INTELLIJ_ENVIRONMENT_READER" ]]; then
        tmux attach -t default 2>/dev/null || tmux new -s default
      fi
    '';
  };

  home.sessionVariables = {
    BROWSER = "brave";
    # Apps Electron/Chromium nativos em Wayland.
    NIXOS_OZONE_WL = "1";
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./files/starship.toml);
  };

  programs.zoxide.enable = true;
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 40%"
      "--border rounded"
      "--info=inline"
      "--layout=reverse"
    ];
  };
  # Aliases de ls/ll/lt definidos acima; os do módulo do eza ficam desligados.
  programs.eza = {
    enable = true;
    enableZshIntegration = false;
  };
  programs.bat = {
    enable = true;
    # base16 usa as cores ANSI do terminal, ou seja, a paleta.
    config.theme = "base16";
  };
  programs.lazygit.enable = true;
  programs.yazi.enable = true;
  programs.btop.enable = true;
  # O thefuck saiu do nixpkgs; o pay-respects é o sucessor compatível.
  programs.pay-respects.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # O tmux.conf é o mesmo do Fedora; o tpm se instala sozinho no primeiro uso.
  home.packages = with pkgs; [
    tmux
    duf
    dust
    ncdu
    procs
    yq-go
    glow
    fastfetch
    yt-dlp
    ffmpeg
  ];
  xdg.configFile."tmux/tmux.conf".text =
    builtins.replaceStrings [ "/bin/zsh" ] [ "${pkgs.zsh}/bin/zsh" ]
      (builtins.readFile ./files/tmux/tmux.conf);
}
