local vars = require("hyprland.variables")

-- ######## Window rules ########

-- (No global opacity rule — every window is fully opaque by default.)

-- Center floating windows (skip xwayland popups)
hl.window_rule({ match = { float = true, xwayland = false }, center = true })

-- Float
local floatClasses = {
    "guifetch",                                  -- FlafyDev/guifetch
    "yad",
    "zenity",
    "wev",
    "org\\.gnome\\.FileRoller",
    "file-roller",
    "blueman-manager",
    "com\\.github\\.GradienceTeam\\.Gradience",
    "feh",
    "imv",
    "system-config-printer",
    "org\\.quickshell",
}
for _, cls in ipairs(floatClasses) do
    hl.window_rule({ match = { class = cls }, float = true })
end

-- Float + size + center groups
local sized = {
    { class = "foot",                                       title = "nmtui",            size = {"60%", "70%"} },
    { class = "org\\.gnome\\.Settings",                                                 size = {"70%", "80%"} },
    { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser",                        size = {"60%", "70%"} },
    { class = "nwg-look",                                                               size = {"50%", "60%"} },
}
for _, r in ipairs(sized) do
    local m = { class = r.class }
    if r.title then m.title = r.title end
    hl.window_rule({ match = m, float = true })
    hl.window_rule({ match = m, size  = r.size })
    hl.window_rule({ match = m, center = true })
end

-- Special workspaces
hl.window_rule({ match = { class = "btop" },                                                 workspace = "special:sysmon" })
hl.window_rule({ match = { class = "feishin|Spotify|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp|com-maxrave-simpmusic-MainKt" }, workspace = "special:music" })
-- Spotify Wayland has no class; match initial_title instead.
hl.window_rule({ match = { initial_title = "Spotify( Free)?" },                              workspace = "special:music" })
hl.window_rule({ match = { class = "discord|equibop|vesktop|whatsapp" },                     workspace = "special:communication" })
hl.window_rule({ match = { class = "Todoist" },                                              workspace = "special:todo" })

-- Dialogs (title-only matches)
local floatTitles = {
    "(Select|Open)( a)? (File|Folder)(s)?",
    "File (Operation|Upload)( Progress)?",
    ".* Properties",
    "Export Image as PNG",
    "GIMP Crash Debug",
    "Save As",
    "Library",
}
for _, t in ipairs(floatTitles) do
    hl.window_rule({ match = { title = t }, float = true })
end

-- Picture-in-picture (resize/move handled by `caelestia resizer`)
local pipTitle = "Picture(-| )in(-| )[Pp]icture"
hl.window_rule({ match = { title = pipTitle }, move              = {"100%-w-2%", "100%-w-3%"} })
hl.window_rule({ match = { title = pipTitle }, keep_aspect_ratio = true })
hl.window_rule({ match = { title = pipTitle }, float             = true })
hl.window_rule({ match = { title = pipTitle }, pin               = true })

-- Creative software → opaque
hl.window_rule({ match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" }, opaque = true })

-- Ueberzugpp
hl.window_rule({ match = { class = "^(ueberzugpp_.*)$" }, float             = true })
hl.window_rule({ match = { class = "^(ueberzugpp_.*)$" }, no_initial_focus  = true })

-- Steam
hl.window_rule({ match = { class = "steam" },                          rounding = 10 })
hl.window_rule({ match = { class = "steam", title = "Friends List" },  float    = true })

-- Games (Steam, Lutris/Wine, Gamescope)
local gameClass = "(steam_app_(default|[0-9]+))|gamescope"
hl.window_rule({ match = { class = gameClass }, opaque        = true })
hl.window_rule({ match = { class = gameClass }, immediate     = true })
hl.window_rule({ match = { class = gameClass }, idle_inhibit  = "always" })

-- Minecraft launcher consoles
hl.window_rule({ match = { class = "com-atlauncher-App",  title = "ATLauncher Console"   }, float = true })
hl.window_rule({ match = { class = "PandoraLauncher",     title = "Minecraft Game Output" }, float = true })

-- Autodesk Fusion 360
hl.window_rule({ match = { class = "fusion360\\.exe", title = "Fusion360|(Marking Menu)" }, no_blur = true })

-- Ugh xwayland popups
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_dim    = true })
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_shadow = true })
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, rounding  = 10 })

-- ######## Workspace rules ########
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = vars.singleWindowGapsOut })

-- ######## Layer rules ########
hl.layer_rule({ match = { namespace = "hyprpicker"    }, animation = "fade" })  -- Colour picker out animation
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })  -- wlogout
hl.layer_rule({ match = { namespace = "selection"     }, animation = "fade" })  -- slurp
hl.layer_rule({ match = { namespace = "wayfreeze"     }, animation = "fade" })

-- Fuzzel
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%" })
hl.layer_rule({ match = { namespace = "launcher" }, blur      = true })

-- Shell
hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim   = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)"           }, animation = "fade" })
