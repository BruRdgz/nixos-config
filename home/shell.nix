{ osConfig, pkgs, ... }:
let
  p = import ./palette.nix;
  flakeDir = osConfig.programs.nh.flake;

  # Barra de status do tmux na paleta (entra no tmux.conf, ver abaixo).
  tmuxStatus = ''
    set -g status-position bottom
    set -g status-left-length 40
    set -g status-right-length 80
    set -g status-style bg="${p.bg1}",fg="${p.fg}"
    set -g message-style bg="${p.bg2}",fg="${p.fg0}"
    set -g pane-border-style fg="${p.bg2}"
    set -g pane-active-border-style fg="${p.accent}"
    set -g mode-style bg="${p.bg3}",fg="${p.fg0}"

    set -g status-left "#[bg=${p.accent},fg=${p.bg0h},bold] #S #[bg=${p.bg1},fg=${p.accent},nobold] "
    set -g status-right "#[fg=${p.gray}] save:#{continuum_status} #[bg=${p.bg1},fg=${p.bg2}]#[bg=${p.bg2},fg=${p.fg}] %H:%M #[bg=${p.bg2},fg=${p.red}]#[bg=${p.red},fg=${p.fg0},bold] %d %b "

    set -g window-status-format "#[fg=${p.bg1},bg=${p.bg2}]#[fg=${p.fg4},bg=${p.bg2}] #I: #W #[fg=${p.bg2},bg=${p.bg1}]"
    set -g window-status-current-format "#[fg=${p.bg1},bg=${p.yellow}]#[fg=${p.bg0h},bg=${p.yellow},bold] #I: #W#{?window_zoomed_flag, 󰊓,} #[fg=${p.yellow},bg=${p.bg1},nobold]"
  '';
in
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

  # Num projeto: `use devshell rust` no .envrc carrega o devShell do repo.
  xdg.configFile."direnv/lib/use_devshell.sh".text = ''
    use_devshell() {
      use flake "${flakeDir}#''${1:-default}"
    }
  '';

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
    aria2
    unar
    nvtopPackages.amd
  ];
  # Barra de status na paleta: sessão em azul-lâmina, janela atual em mostarda.
  # Entra no lugar do marcador, antes do TPM: o continuum processa o
  # #{continuum_status} da barra ao carregar.
  xdg.configFile."tmux/tmux.conf".text =
    builtins.replaceStrings
      [ "/bin/zsh" "# A barra de status é gerada a partir da paleta (home/shell.nix).\n" ]
      [ "${pkgs.zsh}/bin/zsh" tmuxStatus ]
      (builtins.readFile ./files/tmux/tmux.conf);
}
