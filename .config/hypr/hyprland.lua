-- Hyprland Configuration (Lua)
-- Migrated from hyprland.conf; see https://wiki.hypr.land/Configuring/

-- Themes (Uncomment to activate)
-- local c = require("themes.pastel-anime")

-- --- Catppuccin Themes ---
-- The palette is a Lua table (see themes/*.lua), use the fields directly
-- (e.g. c.mauve, c.blue, c.surface1).
-- local c = require("themes.latte")
-- local c = require("themes.frappe")
-- local c = require("themes.macchiato")
local c = require("themes.mocha")

--------------------
---- MONITORS ----
--------------------

hl.monitor({ output = "HDMI-A-4", mode = "2560x1440@144", position = "auto", scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "2560x1440@60", position = "auto", scale = 1 })

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_SCREENSHOTS_DIR", os.getenv("HOME") .. "/pictures/screenshots")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm-app -- hyprpaper")
    hl.exec_cmd("uwsm-app -- waybar")
    hl.exec_cmd("uwsm-app -- swaync")
    hl.exec_cmd("uwsm-app -- hypridle")
    hl.exec_cmd("uwsm-app -- hyprsunset")
    hl.exec_cmd("uwsm-app -- nm-applet")
    hl.exec_cmd("uwsm-app -- blueman-applet")
    hl.exec_cmd("uwsm-app -- /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("uwsm-app -- xsettingsd")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        layout = "dwindle",
        col = {
            active_border = { colors = { c.mauve, c.blue }, angle = 45 },
            inactive_border = c.surface1,
        },
    },

    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        blur = {
            enabled = true,
            size = 4,
            passes = 2,
        },
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
        },
    },

    input = {
        kb_layout = "de",
        kb_variant = "nodeadkeys",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    animations = {
        enabled = true,
    },
})

-- Animations (see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/)
hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "wind" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- WINDOW RULES ----
---------------------

hl.window_rule({
    name = "rofi-opacity",
    match = { class = "^(rofi)$" },
    opacity = "0.9 0.9",
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("rofi -show run"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/wlogout.sh"))
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("~/.config/hypr/scripts/wlogout.sh"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh output"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh screen"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh area"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("killall waybar; waybar"))
