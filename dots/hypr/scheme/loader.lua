-- Always returns a complete Material You palette table.
--   1. Loads scheme/default.lua as the floor (every key guaranteed).
--   2. If ~/.config/hypr/scheme/current.conf exists (caelestia-cli
--      utils/theme.py writes there in hyprlang `$key = hex` format),
--      overlays its values on top.
-- Returning a merged table means a partial/corrupted current.conf
-- can't leave fields nil — downstream colour concatenation always
-- finds a value.

local function fileExists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

local function parseConfScheme(path)
    local t = {}
    for line in io.lines(path) do
        local k, v = line:match("^%$([%w_]+)%s*=%s*(%S+)")
        if k and v then t[k] = v end
    end
    return t
end

local scheme  = require("scheme.default")
local current = (os.getenv("HOME") or "") .. "/.config/hypr/scheme/current.conf"
if fileExists(current) then
    for k, v in pairs(parseConfScheme(current)) do
        scheme[k] = v
    end
end
return scheme
