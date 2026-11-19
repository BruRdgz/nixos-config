{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    # TODO: definir o user.email (deixei de fora porque o repo pode ir para o GitHub).
    settings = {
      user.name = "BruRdgz";
      init.defaultBranch = "main";
      pull.ff = "only";
      fetch.prune = true;
      merge.conflictStyle = "zdiff3";
      diff.colorMoved = "default";
    };
    ignores = [
      "**/.claude/.cc-writes/"
      "**/.claude/settings.local.json"
    ];
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options.navigate = true;
  };
  programs.gh.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
  # Aponta para o scala-psi-host e para uma JDK do coursier: só funciona depois de
  # clonar o projeto e baixar a JDK (o nix-ld cobre os binários do coursier).
  xdg.configFile."helix/languages.toml".source = ./files/helix/languages.toml;

  programs.vscode.enable = true;

  # As mesmas toolchains globais do Fedora; projetos podem ter devShell próprio via direnv.
  home.packages = with pkgs; [
    # Rust
    rustup
    # Scala / JVM
    temurin-bin-21
    coursier
    sbt
    scala-cli
    metals
    # Python
    python3
    uv
    ruff
    pyright
    pre-commit
    # Web
    nodejs
    # C/C++
    gcc
    clang-tools
    cmake
    gnumake
  ];
}
