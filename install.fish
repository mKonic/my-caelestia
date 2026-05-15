#!/usr/bin/env fish

# Top-level installer for the my-caelestia mega-repo.
#
#   ├── dots/    Hyprland config (Lua) + fish + app configs + installer
#   ├── shell/   Quickshell QML overlay + C++ plugin source
#   └── install.fish (this script)
#
# What this does:
#   1. Runs ./dots/install.fish (which installs hyprland + all configs + every app:
#      spotify, discord, vscode-bin, obsidian, cursor-bin).
#   2. Points ~/.config/quickshell/caelestia at ./shell so Quickshell loads our
#      QML overlay on top of the AUR caelestia-shell package's C++ plugin.

argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    'skip-shell-symlink' \
    -- $argv
or exit

if set -q _flag_h
    echo 'usage: ./install.fish [-h] [--noconfirm] [--aur-helper=yay|paru] [--skip-shell-symlink]'
    echo
    echo '  -h, --help               show this help message and exit'
    echo '  --noconfirm              do not confirm package installation'
    echo '  --aur-helper=[yay|paru]  the AUR helper to use (default: paru)'
    echo '  --skip-shell-symlink     skip pointing ~/.config/quickshell/caelestia at ./shell'
    exit
end

set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -l install_dir (path dirname (path resolve (status filename)))
cd $install_dir || exit 1

set_color magenta
echo ':: my-caelestia mega-installer'
set_color normal

# ─── 1. Run the dots installer ────────────────────────────────────────────────
set -l fwd
set -q _flag_noconfirm && set -a fwd --noconfirm
set -q _flag_aur_helper && set -a fwd --aur-helper=$_flag_aur_helper

./dots/install.fish $fwd
or exit 1

# ─── 2. Point Quickshell at our shell/ fork ───────────────────────────────────
if not set -q _flag_skip_shell_symlink
    echo ":: linking $config/quickshell/caelestia -> ./shell"
    mkdir -p $config/quickshell
    if test -e $config/quickshell/caelestia -o -L $config/quickshell/caelestia
        rm -rf $config/quickshell/caelestia
    end
    ln -s (realpath shell) $config/quickshell/caelestia
end

set_color green
echo ':: Done!'
set_color normal
echo 'You may want to:  caelestia shell -k && caelestia shell -d   to restart the shell.'
