# devShells por área, herdados do config antigo. Uso: `nix develop <repo>#rust`, ou
# num projeto, `use devshell rust` no .envrc (helper do direnv em home/shell.nix).
# As toolchains do dia a dia continuam globais (home/dev.nix); estes shells juntam
# o ferramental extra de cada área sem poluir o perfil.
{ pkgs }:
let
  common = with pkgs; [
    git
    just
    fd
    ripgrep
    jq
    bat
    eza
    delta
  ];

  # `check`: binários listados ao entrar, para ver na hora se o shell carregou certo.
  mkShell =
    {
      name,
      packages,
      check,
      env ? { },
      shellHook ? "",
    }:
    pkgs.mkShell {
      name = "${name}-shell";
      packages = common ++ packages;
      inherit env;
      shellHook = ''
        ${shellHook}
        printf '[%s-shell] ' ${name}
        for b in ${toString check}; do
          if command -v "$b" >/dev/null 2>&1; then printf '%s=ok ' "$b"; else printf '%s=FALTANDO ' "$b"; fi
        done
        echo
      '';
    };

  shells = {
    nix = mkShell {
      name = "nix";
      packages = with pkgs; [
        nixfmt
        nil
        statix
        deadnix
        nix-diff
      ];
      check = [
        "nil"
        "nixfmt"
        "statix"
      ];
    };

    rust = mkShell {
      name = "rust";
      packages = with pkgs; [
        cargo
        rustc
        rustfmt
        clippy
        rust-analyzer
        cargo-watch
        cargo-expand
        cargo-audit
        mold
      ];
      env = {
        RUST_BACKTRACE = "1";
        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
      };
      check = [
        "cargo"
        "rustc"
        "rust-analyzer"
      ];
    };

    gcc = mkShell {
      name = "gcc";
      packages = with pkgs; [
        gcc
        gnumake
        cmake
        gdb
        clang
        lldb
        valgrind
        pkg-config
        bear
        lcov
      ];
      env = {
        CC = "gcc";
        CXX = "g++";
      };
      check = [
        "gcc"
        "make"
        "cmake"
        "gdb"
      ];
    };

    java = mkShell {
      name = "java";
      packages = with pkgs; [
        jdk21
        maven
        gradle
      ];
      env.JAVA_HOME = "${pkgs.jdk21}";
      check = [
        "java"
        "mvn"
        "gradle"
      ];
    };

    scala = mkShell {
      name = "scala";
      packages = with pkgs; [
        jdk21
        scala
        sbt
        metals
        coursier
        scalafmt
      ];
      env.JAVA_HOME = "${pkgs.jdk21}";
      check = [
        "scala"
        "sbt"
        "metals"
        "cs"
      ];
    };

    python = mkShell {
      name = "python";
      packages = with pkgs; [
        python3
        uv
        ruff
        pyright
        pipx
      ];
      shellHook = ''export PYTHONPATH="$PWD"'';
      check = [
        "python"
        "uv"
        "ruff"
      ];
    };

    infra = mkShell {
      name = "infra";
      packages = with pkgs; [
        docker-compose
        kubectl
        kubernetes-helm
        k9s
        kubectx
        trivy
        hadolint
        sops
        age
        pgcli
        mycli
        redis
        yq-go
        k6
      ];
      check = [
        "kubectl"
        "helm"
        "k9s"
      ];
    };

    cloud = mkShell {
      name = "cloud";
      packages = with pkgs; [
        awscli2
        aws-vault
        ssm-session-manager-plugin
        backblaze-b2
        rclone
        cloudflared
      ];
      check = [
        "aws"
        "rclone"
        "cloudflared"
      ];
    };

    reverse = mkShell {
      name = "reverse";
      packages = with pkgs; [
        radare2
        ghidra
        gdb
        strace
        ltrace
        binutils
        pwntools
        patchelf
        file
      ];
      check = [
        "r2"
        "ghidra"
        "gdb"
      ];
    };
  };
in
shells // { default = shells.nix; }
