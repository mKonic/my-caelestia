# my-caelestia / dots

Hyprland config (Lua), fish, and app configs. The `dots/install.fish` script installs everything plus a curated set of apps the user always wants.

```
dots/
├── hypr/          # Hyprland config (Lua-only; .conf is deprecated)
├── caelestia/     # shell.json + hypr-user.lua (Caelestia user-overlay files, version-controlled)
├── fish/          # fish shell config, abbrs, functions
├── starship.toml  # Starship prompt
├── btop/          # btop
├── fastfetch/     # fastfetch
├── foot/          # foot terminal
├── firefox/       # Firefox user.js + chrome CSS
├── thunar/        # Thunar
├── uwsm/          # uwsm session
├── micro/         # micro editor
├── spicetify/     # Spotify (Spicetify caelestia theme)
├── vscode/        # VS Code settings, keybinds, caelestia integration extension
├── zed/           # Zed editor
├── zen/           # Zen browser userChrome.css + native messaging app
├── PKGBUILD       # caelestia-meta metapackage
└── install.fish   # installer
```

## Installation

```sh
./install.fish
```

Flags:

```
-h, --help                  show this help message and exit
--noconfirm                 do not confirm package installation
--aur-helper=[yay|paru]     the AUR helper to use (default: paru)
```

The script:

1. Installs `caelestia-meta` (the metapackage in this dir) which pulls Hyprland + `caelestia-cli` + `caelestia-shell` + the rest of the user-space dependencies.
2. Symlinks each config dir under `~/.config/`.
3. Installs and configures: spotify (+ Spicetify caelestia theme), discord (+ OpenAsar + Equicord), visual-studio-code-bin (+ caelestia integration extension), obsidian, cursor-bin. These are **not flag-gated** — they always install. Comment out the relevant block in `install.fish` if you don't want one.

## Hypr layout

Entry point is `hypr/hyprland.lua`, which loads `scheme/`, `hyprland/{variables,env,execs,general,rules,keybinds}.lua`, then merges `custom/*.lua` overlay slots and `~/.config/caelestia/hypr-{vars,user}.lua`.

Hyprland 0.55+ requires Lua; old `.conf` files have been removed. See the top-level `LUA_MIGRATION.md` for the porting runbook and a full mapping of legacy hyprctl dispatchers to `hl.dsp.*`.

## Default keybinds (highlights)

- `Super + Space` — launcher
- `Super + Return` — terminal (ghostty)
- `Super + B` — browser (google-chrome-stable)
- `Super + E` — file manager (dolphin)
- `Super + C` — editor (vscode)
- `Super + Q` — close window
- `Super + Tab` / `Super + Shift + Tab` — next / previous workspace
- `Super + 1..0` — switch to workspace N
- `Super + Shift + 1..0` — move window to workspace N
- `Super + S` — open control center (Caelestia settings)
- `Super + R` — `hyprctl reload`
- `Ctrl + Alt + Delete` — session menu
- `Ctrl + Super + Alt + R` — restart shell

For the full set see `hypr/hyprland/keybinds.lua`.

## Caelestia user overlay (`caelestia/`)

- `shell.json` — bar/dashboard/osd config (battery + brightness OSD + wifi disabled for this desktop; 22 Mullvad WireGuard NYC servers pre-registered for the VPN tab).
- `hypr-user.lua` — extra `exec-once` style hooks (lock power profile to `performance`, set DDC/CI brightness to 100% on login).

Both are symlinked file-by-file into `~/.config/caelestia/` so they coexist with caelestia-cli's auto-generated state (`~/.config/caelestia/monitors/`).

## Notable customizations vs. stock Caelestia

- Hyprland config is Lua (upstream is still hyprlang at the time of fork).
- Default terminal/browser/file-explorer = ghostty / google-chrome-stable / dolphin.
- Launcher rebound from press-Super to `Super + Space` (avoids accidental triggers).
- Move-window-to-workspace = `Super + Shift` (instead of `Super + Alt`).
- `Super + Q` = close window (terminal moved to `Super + Return`).
- `Super + Tab` / `Super + Shift + Tab` = workspace next/prev.
- Monitor pre-configured for DP-1 1920x1080@180.
- Mouse: `sensitivity = -0.5`, `natural_scroll = true`.
- App installs (spotify/discord/vscode-bin/obsidian/cursor-bin) ungated.
- `polkit-gnome` and `wireguard-tools` promoted to hard depends (Caelestia's VPN UI shells out to `pkexec wg-quick`).
