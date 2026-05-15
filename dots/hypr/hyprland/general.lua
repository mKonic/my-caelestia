-- Consolidates general + decoration + animations + input + misc + gestures +
-- group + scrolling + dwindle + binds + cursor + debug into one hl.config{}
-- call (plus separate hl.curve / hl.animation / hl.gesture calls).
-- Source-of-truth values: hyprland/variables.lua.

local vars   = require("hyprland.variables")
local scheme = vars.scheme

hl.config({
    general = {
        layout         = "dwindle",
        allow_tearing  = false,  -- enables `immediate` window rule

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col = {
            active_border   = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },

    decoration = {
        rounding = vars.windowRounding,

        blur = {
            enabled            = vars.blurEnabled,
            xray               = vars.blurXray,
            special            = vars.blurSpecialWs,
            ignore_opacity     = true,   -- enables opacity-aware blur
            new_optimizations  = true,
            popups             = vars.blurPopups,
            input_methods      = vars.blurInputMethods,
            size               = vars.blurSize,
            passes             = vars.blurPasses,
        },

        shadow = {
            enabled      = vars.shadowEnabled,
            range        = vars.shadowRange,
            render_power = vars.shadowRenderPower,
            color        = vars.shadowColour,
        },
    },

    input = {
        kb_layout         = "us",
        numlock_by_default = false,
        repeat_delay      = 250,
        repeat_rate       = 35,

        focus_on_close    = 1,

        sensitivity       = -0.5,
        natural_scroll    = true,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = vars.touchpadDisableTyping,
            scroll_factor        = vars.touchpadScrollFactor,
        },
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        hotspot_padding = 1,
    },

    misc = {
        vrr = 1,

        animate_manual_resizes        = false,
        animate_mouse_windowdragging  = false,

        disable_hyprland_logo    = true,
        force_default_wallpaper  = 0,

        on_focus_under_fullscreen  = 2,
        allow_session_lock_restore = true,
        middle_click_paste         = false,
        focus_on_activate          = true,
        session_lock_xray          = true,

        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        background_color = "rgb(" .. scheme.surfaceContainer .. ")",
    },

    debug = {
        error_position = 1,
    },

    gestures = {
        workspace_swipe_distance               = 700,
        workspace_swipe_cancel_ratio           = 0.15,
        workspace_swipe_min_speed_to_force     = 5,
        workspace_swipe_direction_lock         = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new             = true,
    },

    group = {
        col = {
            border_active          = vars.activeWindowBorderColour,
            border_inactive        = vars.inactiveWindowBorderColour,
            border_locked_active   = vars.activeWindowBorderColour,
            border_locked_inactive = vars.inactiveWindowBorderColour,
        },
        groupbar = {
            font_family             = "JetBrains Mono NF",
            font_size               = 15,
            gradients               = true,
            gradient_round_only_edges = false,
            gradient_rounding       = 5,
            height                  = 25,
            indicator_height        = 0,
            gaps_in                 = 3,
            gaps_out                = 3,
            text_color              = "rgb("  .. scheme.onPrimary .. ")",
            col = {
                active          = "rgba(" .. scheme.primary  .. "d4)",
                inactive        = "rgba(" .. scheme.outline  .. "d4)",
                locked_active   = "rgba(" .. scheme.primary  .. "d4)",
                locked_inactive = "rgba(" .. scheme.secondary .. "d4)",
            },
        },
    },

    -- Scrolling layout
    scrolling = {
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        column_width             = 0.5,
        follow_focus             = true,
        follow_min_visible       = 0.0,
        explicit_column_widths   = "0.35, 0.5, 0.65, 1.0",
    },

    animations = {
        enabled = true,
    },
})

-- ##### Animation curves #####
hl.curve("specialWorkSwitch", { type = "bezier", points = { {0.05, 0.7}, {0.1,  1   } } })
hl.curve("emphasizedAccel",   { type = "bezier", points = { {0.3,  0  }, {0.8,  0.15} } })
hl.curve("emphasizedDecel",   { type = "bezier", points = { {0.05, 0.7}, {0.1,  1   } } })
hl.curve("standard",          { type = "bezier", points = { {0.2,  0  }, {0,    1   } } })

-- ##### Animations #####
hl.animation({ leaf = "layersIn",   enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 4, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, bezier = "standard" })

hl.animation({ leaf = "windowsIn",  enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove",enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard" })

hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })

hl.animation({ leaf = "fade",    enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border",  enabled = true, speed = 6, bezier = "standard" })

-- ##### Gestures #####
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = vars.gestureFingers,        direction = "up",
    action = function() hl.dispatch(hl.dsp.workspace.toggle_special("special")) end })
hl.gesture({ fingers = vars.gestureFingers,        direction = "down",
    action = function() hl.dispatch(hl.dsp.exec_cmd("caelestia toggle specialws")) end })
hl.gesture({ fingers = vars.gestureFingersMore,    direction = "down",
    action = function() hl.dispatch(hl.dsp.exec_cmd("systemctl suspend-then-hibernate")) end })
