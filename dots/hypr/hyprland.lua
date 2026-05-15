-- my-caelestia Hyprland config (Lua)
-- Mirrors the old hyprland.conf load order. User overrides come from
-- ~/.config/caelestia/hypr-{vars,user}.lua (created here if missing) and from
-- hypr/custom/*.lua hooks (end-4 layout).

local home  = os.getenv("HOME")
local cConf = home .. "/.config/caelestia"

-- Hyprland keeps the Lua state (incl. package.loaded) alive across reloads,
-- so a plain require() would return the cached module from the previous
-- evaluation and any edits to scheme/hyprland/custom files would silently
-- have no effect. Drop those prefixes from the cache before requiring.
for name in pairs(package.loaded) do
    local p = name:sub(1, 8)
    if p == "scheme.l" or p == "scheme.d" or p == "scheme.c"
       or name:sub(1, 9) == "hyprland." or name:sub(1, 7) == "custom." then
        package.loaded[name] = nil
    end
end

-- Load a file only if it exists (so missing user overrides don't crash reload).
local function safeLoad(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        dofile(path)
    end
end

-- Auto-create user override stubs (replaces hypr/scripts/configs.fish).
os.execute("mkdir -p " .. cConf)
for _, fname in ipairs({ "hypr-vars.lua", "hypr-user.lua" }) do
    local path = cConf .. "/" .. fname
    if not io.open(path, "r") then
        local f = io.open(path, "w")
        if f then f:close() end
    end
end

-- ##### Scheme / variables (must precede modules that consume them) #####
require("scheme.loader")
require("hyprland.variables")
require("custom.variables")
safeLoad(cConf .. "/hypr-vars.lua")

-- ##### Monitor (fork default) #####
hl.monitor({ output = "DP-1", mode = "1920x1080@180", position = "0x0", scale = "1" })

-- ##### Default modules #####
require("hyprland.env")
require("custom.env")

require("hyprland.execs")
require("custom.execs")

require("hyprland.general")
require("custom.general")

require("hyprland.rules")
require("custom.rules")

require("hyprland.keybinds")
require("custom.keybinds")

-- ##### User overrides (caelestia convention) #####
safeLoad(cConf .. "/hypr-user.lua")
