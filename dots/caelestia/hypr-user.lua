-- Lock power profile to performance + monitor brightness to 100% on login
hl.on("hyprland.start", function()
    hl.exec_cmd("powerprofilesctl set performance")
    hl.exec_cmd("sleep 2 && ddcutil setvcp 10 100 || true")
end)
