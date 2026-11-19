# Paleta "Pista molhada", tirada do wallpaper (home/files/wallpapers/pista.png):
# sombras azul-marinho, céu nublado, amarelo da Ferrari e as cores da pista.
# Todos os módulos de aparência leem daqui; trocar o tema = trocar este arquivo.
rec {
  # Fundos (sombras do asfalto)
  bg0 = "#14171d";
  bg1 = "#1f242c";
  bg2 = "#2b313a";
  bg3 = "#3a414c";
  # Texto (céu nublado)
  fg = "#d7dadb";
  fgDim = "#a0a2a3";
  muted = "#6b7079";

  # Destaques
  accent = "#f0c419"; # amarelo Ferrari
  alert = "#e5484d"; # lanternas
  magenta = "#d6409f"; # banner FINISH
  orange = "#e8924f"; # torre
  teal = "#4fb3bf"; # bandeiras
  green = "#8fb573";
  blue = "#6c9fd6";

  # 16 cores do terminal
  ansi = {
    black = bg2;
    red = alert;
    green = green;
    yellow = accent;
    blue = blue;
    magenta = magenta;
    cyan = teal;
    white = fgDim;
    brightBlack = muted;
    brightRed = "#f07175";
    brightGreen = "#a9cc8c";
    brightYellow = "#f7d65a";
    brightBlue = "#8fb8e6";
    brightMagenta = "#e46cb5";
    brightCyan = "#76c9d3";
    brightWhite = fg;
  };

  font = {
    ui = "Inter";
    mono = "JetBrains Mono";
    icons = "JetBrainsMono Nerd Font";
  };
}
