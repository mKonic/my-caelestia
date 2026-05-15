-- Translated from hypr/hyprland/keybinds.conf and cross-referenced against
-- the actual hl.dsp.* surface area of Hyprland 0.55.1 (enumerated via
-- `hyprctl dispatch 'hl.dsp.exec_cmd("logger -t hldsp " .. ...)'`).
--
-- Note on legacy hyprctl: under a .lua config Hyprland wraps every
-- `hyprctl dispatch X Y` call as `return hl.dispatch(X Y)` and evaluates
-- it as Lua, so legacy space-separated syntax is permanently broken.
-- The shorthand for `hyprctl dispatch foo` is `hyprctl dispatch
-- 'hl.dispatch(hl.dsp.foo())'`. All workarounds below use the real Lua
-- API directly.

local vars   = require("hyprland.variables")

-- Workspace navigation math. wsaction.fish translated inline because the
-- script itself shells out to `hyprctl dispatch workspace N` (legacy form,
-- now broken).
local function inGroup(n)
    local active = hl.get_active_workspace().id
    return math.floor((active - 1) / 10) * 10 + n
end
local function acrossGroups(g)
    local active = hl.get_active_workspace().id
    local slot   = active % 10
    if slot == 0 then slot = 10 end
    return (g - 1) * 10 + slot
end

-- Submap reset (`exec = hyprctl dispatch submap global` in the original) was
-- a no-op: we never enter a non-default submap. Dropped during port.

-- ##### Shell keybinds #####
-- Note: hl.dsp.global(...) bound directly via hl.bind() doesn't reliably
-- fire on 0.55.1 (verified empirically — same dispatcher works fine via
-- `hyprctl dispatch 'hl.dsp.global("caelestia:launcher")'`, but the bind
-- doesn't trigger it). Wrap every global in an explicit function() so
-- Hyprland calls hl.dispatch() itself.
local function fire(d) return function() hl.dispatch(d) end end
local function fireGlobal(name)
    return function() hl.dispatch(hl.dsp.global(name)) end
end

-- Launcher rebind (replaces upstream press-Super-alone trigger).
-- The "launcher" CustomShortcut puts its toggle in onReleased, and
-- Hyprland 0.55.1's hl.dsp.global from a keybind only reliably fires
-- the onPressed half. Go through the drawers IPC to skip that path.
hl.bind("SUPER + Space",
    hl.dsp.exec_cmd("qs -c caelestia ipc call drawers toggle launcher"),
    { description = "Launcher" })

-- Misc shell bindings
hl.bind(vars.kbSession,    fireGlobal("caelestia:session"))
hl.bind(vars.kbShowSidebar, fireGlobal("caelestia:sidebar"))
hl.bind(vars.kbClearNotifs, fireGlobal("caelestia:clearNotifs"), { locked = true })
hl.bind(vars.kbShowPanels,  fireGlobal("caelestia:showall"))
hl.bind(vars.kbLock,        fireGlobal("caelestia:lock"))

-- Restore lock (Super+Alt+L): kick the shell daemon, then re-lock
hl.bind(vars.kbRestoreLock, hl.dsp.exec_cmd("caelestia shell -d"), { locked = true })
hl.bind(vars.kbRestoreLock, fireGlobal("caelestia:lock"),       { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   fireGlobal("caelestia:brightnessUp"),   { locked = true })
hl.bind("XF86MonBrightnessDown", fireGlobal("caelestia:brightnessDown"), { locked = true })

-- Media
hl.bind("CTRL+SUPER + Space", fireGlobal("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPlay",      fireGlobal("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPause",     fireGlobal("caelestia:mediaToggle"), { locked = true })
hl.bind("CTRL+SUPER + Equal", fireGlobal("caelestia:mediaNext"),   { locked = true })
hl.bind("XF86AudioNext",      fireGlobal("caelestia:mediaNext"),   { locked = true })
hl.bind("CTRL+SUPER + Minus", fireGlobal("caelestia:mediaPrev"),   { locked = true })
hl.bind("XF86AudioPrev",      fireGlobal("caelestia:mediaPrev"),   { locked = true })
hl.bind("XF86AudioStop",      fireGlobal("caelestia:mediaStop"),   { locked = true })

-- Kill / restart (bindr = release-triggered)
hl.bind("CTRL+SUPER+SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"),
        { release = true })
hl.bind("CTRL+SUPER+ALT + R",   hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"),
        { release = true })

-- ##### Workspaces #####
-- Go to workspace N (in current group) / move window to workspace N.
-- The "group" variants jump to the same slot in a different group of 10.
for i = 1, 10 do
    local n = (i == 10) and "0" or tostring(i)
    hl.bind(vars.kbGoToWs           .. " + " .. n, function() hl.dispatch(hl.dsp.focus({       workspace = tostring(inGroup(i))       })) end)
    hl.bind(vars.kbGoToWsGroup      .. " + " .. n, function() hl.dispatch(hl.dsp.focus({       workspace = tostring(acrossGroups(i))  })) end)
    hl.bind(vars.kbMoveWinToWs      .. " + " .. n, function() hl.dispatch(hl.dsp.window.move({ workspace = tostring(inGroup(i))       })) end)
    hl.bind(vars.kbMoveWinToWsGroup .. " + " .. n, function() hl.dispatch(hl.dsp.window.move({ workspace = tostring(acrossGroups(i))  })) end)
end

-- Go to workspace -1 / +1
hl.bind("SUPER + mouse_down",       hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + mouse_up",         hl.dsp.focus({ workspace = "+1" }))
hl.bind(vars.kbPrevWs,              hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind(vars.kbNextWs,              hl.dsp.focus({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER + Page_Up",          hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + Page_Down",        hl.dsp.focus({ workspace = "+1" }), { repeating = true })

-- Go to workspace group -1 / +1 (10 workspaces per group)
hl.bind("CTRL+SUPER + mouse_down",  hl.dsp.focus({ workspace = "-10" }))
hl.bind("CTRL+SUPER + mouse_up",    hl.dsp.focus({ workspace = "+10" }))

-- Settings (control center) and Hyprland config reload.
-- Super+Alt+S still moves window→special:special; 3-finger-down gesture
-- still toggles the special workspace.
hl.bind(vars.kbSettings, fireGlobal("caelestia:controlCenter"))
hl.bind(vars.kbReload,   hl.dsp.exec_cmd("hyprctl reload"))

-- Move active window to workspace -1 / +1
hl.bind("SUPER+ALT + Page_Up",         hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER+ALT + Page_Down",       hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER+ALT + mouse_down",      hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER+ALT + mouse_up",        hl.dsp.window.move({ workspace = "+1" }))
hl.bind("CTRL+SUPER+SHIFT + right",    hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("CTRL+SUPER+SHIFT + left",     hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

-- Move to/from special workspace
hl.bind("CTRL+SUPER+SHIFT + up",   hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL+SUPER+SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER+ALT + S",           hl.dsp.window.move({ workspace = "special:special" }))

-- Toggle the generic special:special scratchpad visibility
hl.bind("SUPER + Backslash",       fire(hl.dsp.workspace.toggle_special("special")))

-- ##### Window groups #####
-- API mapping (enumerated from hl.dsp via logger introspection on 0.55.1):
--   cyclenext            → hl.dsp.window.cycle_next()
--   cyclenext prev       → hl.dsp.window.cycle_next({direction = "prev"})
--   changegroupactive f  → hl.dsp.group.next()
--   changegroupactive b  → hl.dsp.group.prev()
--   togglegroup          → hl.dsp.group.toggle()
--   moveoutofgroup       → hl.dsp.group.move_window()
--   lockactivegroup      → hl.dsp.group.lock("toggle")
hl.bind(vars.kbWindowGroupCycleNext, fire(hl.dsp.window.cycle_next()),                       { repeating = true })
hl.bind(vars.kbWindowGroupCyclePrev, fire(hl.dsp.window.cycle_next({ direction = "prev" })), { repeating = true })
hl.bind("CTRL+ALT + Tab",            fire(hl.dsp.group.next()),                              { repeating = true })
hl.bind("CTRL+SHIFT+ALT + Tab",      fire(hl.dsp.group.prev()),                              { repeating = true })
hl.bind(vars.kbToggleGroup,          fire(hl.dsp.group.toggle()))
hl.bind(vars.kbUngroup,              fire(hl.dsp.group.move_window()))
hl.bind("SUPER+SHIFT + Comma",       fire(hl.dsp.group.lock("toggle")))

-- ##### Window actions #####
-- Focus
hl.bind("SUPER + left",   hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right",  hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up",     hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down",   hl.dsp.focus({ direction = "d" }))

-- Move
hl.bind("SUPER+SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER+SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER+SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER+SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize. 0.55.1's hl.dsp.window.resize only accepts numeric x/y (no "%"
-- strings, no resize_active variant), so percentage resizes are computed
-- from the active monitor's pixel size at bind-fire time.
local function relResizePct(dxPct, dyPct)
    return function()
        local m = hl.get_active_monitor()
        hl.dispatch(hl.dsp.window.resize({
            x = math.floor(m.width  * dxPct / 100),
            y = math.floor(m.height * dyPct / 100),
            relative = true,
        }))
    end
end
hl.bind("SUPER + Minus",       relResizePct(-10,  0), { repeating = true })
hl.bind("SUPER + Equal",       relResizePct( 10,  0), { repeating = true })
hl.bind("SUPER+SHIFT + Minus", relResizePct(  0,-10), { repeating = true })
hl.bind("SUPER+SHIFT + Equal", relResizePct(  0, 10), { repeating = true })
hl.bind("SUPER+ALT + left",    relResizePct(-10,  0), { repeating = true })
hl.bind("SUPER+ALT + right",   relResizePct( 10,  0), { repeating = true })
hl.bind("SUPER+ALT + up",      relResizePct(  0,-10), { repeating = true })
hl.bind("SUPER+ALT + down",    relResizePct(  0, 10), { repeating = true })

-- Mouse drag move/resize.  drag({resize=true}) is the discovered form
-- for mouse-drag-resize (no-args resize is rejected with "x and y are
-- required").
hl.bind("SUPER + mouse:272",   hl.dsp.window.drag(),                  { mouse = true })
hl.bind(vars.kbMoveWindow,     hl.dsp.window.drag(),                  { mouse = true })
hl.bind("SUPER + mouse:273",   hl.dsp.window.drag({ resize = true }), { mouse = true })
hl.bind(vars.kbResizeWindow,   hl.dsp.window.drag({ resize = true }), { mouse = true })

-- Center / resize-and-center.  "exact 55% 70%" → compute pixels first.
hl.bind("CTRL+SUPER + Backslash",     hl.dsp.window.center({ respect_monitor_reserved = true }))
hl.bind("CTRL+SUPER+ALT + Backslash", function()
    local m = hl.get_active_monitor()
    hl.dispatch(hl.dsp.window.resize({ x = math.floor(m.width * 0.55), y = math.floor(m.height * 0.70) }))
    hl.dispatch(hl.dsp.window.center({ respect_monitor_reserved = true }))
end)

-- Picture-in-picture
hl.bind(vars.kbWindowPip,         hl.dsp.exec_cmd("caelestia resizer pip"))

-- Pin / fullscreen / float / close
hl.bind(vars.kbPinWindow,                hl.dsp.window.pin())
hl.bind(vars.kbWindowFullscreen,         hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }))
hl.bind(vars.kbToggleWindowFloating,     hl.dsp.window.float({ action = "toggle" }))
hl.bind(vars.kbCloseWindow,              hl.dsp.window.close())

-- ##### Special workspace toggles (sysmon/music/communication/todo) #####
hl.bind(vars.kbSystemMonitor, hl.dsp.exec_cmd("caelestia toggle sysmon"))
hl.bind(vars.kbMusic,         hl.dsp.exec_cmd("caelestia toggle music"))
hl.bind(vars.kbCommunication, hl.dsp.exec_cmd("caelestia toggle communication"))
hl.bind(vars.kbTodo,          hl.dsp.exec_cmd("caelestia toggle todo"))

-- ##### Apps #####
hl.bind(vars.kbTerminal,     hl.dsp.exec_cmd("app2unit -- " .. vars.terminal))
hl.bind(vars.kbBrowser,      hl.dsp.exec_cmd("app2unit -- " .. vars.browser))
hl.bind(vars.kbEditor,       hl.dsp.exec_cmd("app2unit -- " .. vars.editor))
hl.bind("SUPER + G",         hl.dsp.exec_cmd("app2unit -- github-desktop"))
hl.bind(vars.kbFileExplorer, hl.dsp.exec_cmd("app2unit -- " .. vars.fileExplorer))
hl.bind("SUPER+ALT + E",     hl.dsp.exec_cmd("app2unit -- nemo"))
hl.bind("CTRL+ALT + Escape", hl.dsp.exec_cmd("app2unit -- qps"))
hl.bind("CTRL+ALT + V",      hl.dsp.exec_cmd("app2unit -- pavucontrol"))

-- ##### Utilities #####
hl.bind("Print",                 hl.dsp.exec_cmd("caelestia screenshot"), { locked = true })
hl.bind("SUPER+SHIFT + S",       fireGlobal("caelestia:screenshotFreeze"))
hl.bind("SUPER+SHIFT+ALT + S",   fireGlobal("caelestia:screenshot"))
hl.bind("SUPER+ALT + R",         hl.dsp.exec_cmd("caelestia record -s"))
hl.bind("CTRL+ALT + R",          hl.dsp.exec_cmd("caelestia record"))
hl.bind("SUPER+SHIFT+ALT + R",   hl.dsp.exec_cmd("caelestia record -r"))
hl.bind("SUPER+SHIFT + C",       hl.dsp.exec_cmd("hyprpicker -a"))

-- ##### Volume #####
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
hl.bind("SUPER+SHIFT + M",  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true })
-- Perceptual (cubic) volume stepping. Linear amplitude (what wpctl writes
-- natively) sounds flat 0-70% and jumps in the upper half; cubing the
-- slider value approximates loudness perception. See hypr/scripts/volstep.fish.
hl.bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("~/.config/hypr/scripts/volstep.fish up "   .. vars.volumeStep),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd("~/.config/hypr/scripts/volstep.fish down " .. vars.volumeStep),
    { locked = true, repeating = true })

-- ##### Sleep #####
hl.bind("SUPER+SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), { locked = true })

-- ##### Clipboard / emoji picker #####
hl.bind("SUPER + V",            hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind("SUPER+ALT + V",        hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
hl.bind("SUPER + Period",       hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))
hl.bind("CTRL+SHIFT+ALT + V",   hl.dsp.exec_cmd(
    "sleep 0.5s && ydotool type -d 1 \"$(cliphist list | head -1 | cliphist decode)\""
), { locked = true })

-- ##### Testing #####
hl.bind("SUPER+ALT + f12", hl.dsp.exec_cmd(
    "notify-send -u low -i dialog-information-symbolic 'Test notification' "
    .. "\"Here's a really long message to test truncation and wrapping\\nYou can middle click "
    .. "or flick this notification to dismiss it!\" -a 'Shell' "
    .. "-A \"Test1=I got it!\" -A \"Test2=Another action\""
), { locked = true })
