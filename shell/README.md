# my-caelestia / shell

Quickshell QML overlay (plus C++ plugin source) for the my-caelestia desktop. Originally forked from [caelestia-dots/shell](https://github.com/caelestia-dots/shell) but no longer tracked against upstream — diverging on its own path.

## Layout

```
shell/
├── shell.qml           # entry point
├── modules/            # top-level UI modules (bar, dashboard, launcher, …)
├── components/         # reusable widgets
├── services/           # Quickshell services (Hypr, Audio, Bluetooth, VPN, …)
├── utils/              # helpers
├── assets/             # icons, images, fonts
├── plugin/             # C++ Qt QML plugin (not currently built — provided by AUR caelestia-shell)
├── extras/             # standalone version.cpp + cmake helper
├── nix/                # Nix module + default.nix
├── flake.nix           # Nix flake for reproducible plugin builds
├── .envrc              # direnv hook (auto-builds plugin/ with cmake)
└── scripts/            # qml-lint helpers
```

## How this is loaded

The AUR `caelestia-shell` package installs a baseline QML tree to `/etc/xdg/quickshell/caelestia/` and the compiled C++ plugin to a system QML import path. Your fork overrides the QML by symlinking `~/.config/quickshell/caelestia` → this directory (XDG search-path wins over system).

Until the C++ plugin is rebuilt locally, the binary plugin still comes from the AUR package. To extend the C++ side from this fork, build `plugin/` (CMake or the Nix flake), set `QML2_IMPORT_PATH` to your build's `qml/` dir, and either uninstall `caelestia-shell` or replace `/etc/xdg/quickshell/caelestia/` with a symlink to this tree.

## Customizations vs. stock Caelestia

- `BatteryMonitor.qml` removed (desktop machine, no battery).
- `services/Hypr.qml` patched: legacy `hyprctl dispatch` strings are translated to Lua at the chokepoint so the shell continues to work under Hyprland 0.55+ Lua configs.
- `shell.json` config knobs disable battery widgets everywhere, brightness OSD/scroll, wifi/network indicators; VPN tab pre-populated with Mullvad WireGuard NYC providers.

## Restarting

After QML edits, Quickshell's `settings.watchFiles: true` picks them up live. For structural changes (deleting modules), kick the daemon:

```sh
caelestia shell -k && caelestia shell -d
```

## License

GPL-3.0 (inherited).
