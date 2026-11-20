-- Config do Hyprland (API Lua). Referência: https://wiki.hypr.land/configuring/
-- Tipos da API: ~/.config/hypr/.luarc.json aponta para os stubs do pacote.

local terminal    = "kitty"
local menu        = "fuzzel"
local fileManager = "nautilus"
local mainMod     = "SUPER"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 6,
        border_size      = 0,
        resize_on_border = true,
        layout           = "dwindle",
    },
    decoration = {
        rounding     = 8,
        -- Sem bordas, o foco é indicado escurecendo levemente as janelas inativas.
        dim_inactive = true,
        dim_strength = 0.1,
        blur = {
            enabled = true,
            size    = 6,
            passes  = 2,
        },
    },
    dwindle = {
        preserve_split = true,
    },
    -- O wallpaper vem do hyprpaper (home/theme.nix).
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- Sem as frases aleatórias que o Hyprland desenha sobre o wallpaper.
        disable_splash_rendering = true,
        -- Mexer o mouse ou teclar acorda o monitor após o dpms off do hypridle.
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },
    input = {
        kb_layout  = "br,us",
        -- custom:scroll_led_numlock: o backlight do teclado (LED do Scroll Lock) segue o Num Lock.
        kb_options = "grp:win_space_toggle,custom:scroll_led_numlock",
        numlock_by_default = true,
        follow_mouse = 1,
    },
})

---------------
---- BINDS ----
---------------

hl.bind(mainMod .. " + RETURN",    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("loginctl lock-session"))
-- A sessão roda sob o UWSM; sair por ele encerra os serviços da sessão corretamente.
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("wlogout -b 5 -T 260 -B 260 -L 120 -R 120"))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("brave"))
-- Prints: região/janela vão pro clipboard; Super+Print salva a tela em ~/Imagens.
hl.bind("Print",                   hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd("hyprshot -m output -o ~/Imagens"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10 -- workspace 10 fica na tecla 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---------------
---- RULES ----
---------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Corrige arrastar janelas XWayland.
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
