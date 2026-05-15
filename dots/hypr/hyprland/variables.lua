-- Defaults shared by general.lua, execs.lua, env.lua, group.lua, rules.lua.
-- Mirrors hypr/variables.conf $vars. Scheme colors come from scheme/loader.lua.

local scheme = require("scheme.loader")

return {
    -- Scheme passthrough (group.lua, misc background, etc.)
    scheme = scheme,

    -- Apps (referenced by keybinds.lua)
    terminal       = "ghostty",
    browser        = "google-chrome-stable",
    editor         = "code",
    fileExplorer   = "dolphin",

    -- Touchpad / gestures
    touchpadDisableTyping = true,
    touchpadScrollFactor  = 0.3,
    workspaceSwipeFingers = 4,
    gestureFingers        = 3,
    gestureFingersMore    = 4,

    -- Blur
    blurEnabled       = true,
    blurSpecialWs     = false,
    blurPopups        = true,
    blurInputMethods  = true,
    blurSize          = 8,
    blurPasses        = 2,
    blurXray          = false,

    -- Shadow
    shadowEnabled     = true,
    shadowRange       = 20,
    shadowRenderPower = 3,
    shadowColour      = "rgba(" .. scheme.surface .. "d4)",

    -- Gaps
    workspaceGaps        = 20,
    windowGapsIn         = 5,
    windowGapsOut        = 10,
    singleWindowGapsOut  = 20,

    -- Window styling
    windowRounding             = 15,
    windowBorderSize           = 1,
    activeWindowBorderColour   = "rgba(" .. scheme.primary           .. "e6)",
    inactiveWindowBorderColour = "rgba(" .. scheme.onSurfaceVariant  .. "11)",

    -- Misc
    volumeStep   = 10,
    cursorTheme  = "sweet-cursors",
    cursorSize   = 24,

    -- ##### Keybind mods (consumed by keybinds.lua) #####
    -- Mod-prefix only (concatenate with " + KEY" in bind calls)
    kbMoveWinToWs       = "SUPER+SHIFT",
    kbMoveWinToWsGroup  = "CTRL+SUPER+ALT",
    kbGoToWs            = "SUPER",
    kbGoToWsGroup       = "CTRL+SUPER",

    -- Full bind strings (mod + key, drop straight into hl.bind)
    kbNextWs            = "SUPER + Tab",
    kbPrevWs            = "SUPER+SHIFT + Tab",
    -- kbToggleSpecialWs dropped — Super+S now opens settings.
    -- 3-finger-down gesture still toggles the special workspace (see general.lua).
    kbWindowGroupCycleNext = "ALT + Tab",
    kbWindowGroupCyclePrev = "SHIFT+ALT + Tab",
    kbUngroup           = "SUPER + U",
    kbToggleGroup       = "SUPER + Comma",
    kbMoveWindow        = "SUPER + Z",
    kbResizeWindow      = "SUPER + X",
    kbWindowPip         = "SUPER+ALT + Backslash",
    kbPinWindow         = "SUPER + P",
    kbWindowFullscreen  = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER+ALT + F",
    kbToggleWindowFloating = "SUPER+ALT + Space",
    kbCloseWindow       = "SUPER + Q",
    kbSystemMonitor     = "CTRL+SHIFT + Escape",
    kbMusic             = "SUPER + M",
    kbCommunication     = "SUPER + D",
    kbTodo              = "SUPER + T",   -- moved from R; Super+R now reloads Hyprland
    kbTerminal          = "SUPER + Return",
    kbBrowser           = "SUPER + B",
    kbEditor            = "SUPER + C",
    kbFileExplorer      = "SUPER + E",
    kbSession           = "CTRL+ALT + Delete",
    kbShowSidebar       = "SUPER + N",
    kbClearNotifs       = "CTRL+ALT + C",
    kbShowPanels        = "SUPER + K",
    kbLock              = "SUPER + L",
    kbRestoreLock       = "SUPER+ALT + L",
    kbSettings          = "SUPER + S",   -- opens caelestia control center
    kbReload            = "SUPER + R",   -- hyprctl reload
}
