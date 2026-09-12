-- LPDE example profile for Hyprland 0.56.x.
-- This file uses Hyprland's native Lua configuration API.

local terminal    = "foot"
local fileManager = "hyprfm"
local browser     = "chromium --ozone-platform=wayland --enable-features=VaapiVideoDecodeLinuxGL"
local mainMod     = "SUPER"

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell")
    hl.exec_cmd("if command -v hyprpolkitagent >/dev/null 2>&1; then hyprpolkitagent; elif [ -x /usr/lib/hyprpolkitagent/hyprpolkitagent ]; then /usr/lib/hyprpolkitagent/hyprpolkitagent; elif [ -x /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1 ]; then /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1; fi")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
end)

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in         = 3,
        gaps_out        = 5,
        border_size     = 1,
        resize_on_border = true,
        allow_tearing   = false,
        layout          = "dwindle",
        snap = {
            enabled       = true,
            window_gap    = 4,
            monitor_gap   = 5,
            respect_gaps  = true,
        },
    },
    decoration = {
        rounding       = 5,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },
    animations = { enabled = false },
})

hl.config({
    dwindle = { preserve_split = true },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
    input = {
        kb_layout     = "us,ru",
        kb_variant    = "",
        kb_model      = "",
        kb_options    = "grp:alt_shift_toggle",
        kb_rules      = "",
        follow_mouse  = 1,
        sensitivity   = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },
    binds = { workspace_back_and_forth = true },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Applications.
local function modBind(key, dispatcher, flags)
    local binding = mainMod .. " + " .. key
    if flags then
        hl.bind(binding, dispatcher, flags)
    else
        hl.bind(binding, dispatcher)
    end
end

modBind("T", hl.dsp.exec_cmd(terminal))
modBind("E", hl.dsp.exec_cmd(fileManager))
modBind("B", hl.dsp.exec_cmd(browser))

-- Session and windows.
modBind("Q", hl.dsp.window.close())
modBind("SHIFT + M", hl.dsp.exec_cmd("uwsm stop"))
modBind("F", hl.dsp.window.fullscreen({ action = "toggle" }))
modBind("V", hl.dsp.window.float({ action = "toggle" }))
modBind("L", hl.dsp.exec_cmd("hyprlock"))

-- Focus and move windows.
for _, direction in ipairs({ "left", "right", "up", "down" }) do
    modBind(direction, hl.dsp.focus({ direction = direction }))
    modBind("SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }))
end

-- Workspaces 1-10; workspace 10 is bound to 0.
for i = 1, 10 do
    local key = i % 10
    modBind(key, hl.dsp.focus({ workspace = i }))
    modBind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

modBind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
modBind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))
modBind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
modBind("mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(
    "PRINT",
    hl.dsp.exec_cmd([[sh -c 'mkdir -p "$HOME/Pictures/Screenshots"; grim -g "$(slurp)" "$HOME/Pictures/Screenshots/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"']])
)
modBind("SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- Multimedia and brightness keys work while the screen is locked.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Quickshell IPC.
modBind("D", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
modBind("SHIFT + N", hl.dsp.exec_cmd("qs ipc call notifications dnd_toggle"))
modBind("O", hl.dsp.exec_cmd("qs ipc call monitors toggle"))
modBind("SHIFT + O", hl.dsp.exec_cmd("qs ipc call monitors refresh"))

hl.window_rule({
    name = "float-nmtui",
    match = { class = "^lpde-nmtui$" },
    float = true,
})

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
