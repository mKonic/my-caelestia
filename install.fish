#!/usr/bin/env fish

# Top-level installer for the my-caelestia mega-repo.
#
#   ├── dots/    Hyprland config (Lua) + fish + app configs + installer
#   ├── shell/   Quickshell QML overlay + C++ plugin source
#   └── install.fish (this script)
#
# What this does:
#   1. Downloads caelestia-cli and caelestia-shell .pkg.tar.zst files from the
#      latest GitHub release and installs them via pacman.
#   2. Runs ./dots/install.fish (which installs hyprland + all configs + every app:
#      spotify, discord, vscode-bin, obsidian, cursor-bin).
#   3. Points ~/.config/quickshell/caelestia at ./shell so Quickshell loads our
#      QML overlay on top of the installed C++ plugin.

argparse -n 'install.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    'skip-packages' \
    'skip-shell-symlink' \
    -- $argv
or exit

if set -q _flag_h
    echo 'usage: ./install.fish [-h] [--noconfirm] [--aur-helper=yay|paru] [--skip-packages] [--skip-shell-symlink]'
    echo
    echo '  -h, --help               show this help message and exit'
    echo '  --noconfirm              do not confirm package installation'
    echo '  --aur-helper=[yay|paru]  the AUR helper to use (default: paru)'
    echo '  --skip-packages          skip downloading caelestia-cli/shell from the latest GitHub release'
    echo '  --skip-shell-symlink     skip pointing ~/.config/quickshell/caelestia at ./shell'
    exit
end

set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -l install_dir (path dirname (path resolve (status filename)))
cd $install_dir || exit 1

set_color magenta
echo ':: my-caelestia mega-installer'
set_color normal

# ─── 1. Install caelestia-cli and caelestia-shell from the latest GitHub release
if not set -q _flag_skip_packages
    set -l repo 'mKonic/my-caelestia'
    set -l api "https://api.github.com/repos/$repo/releases/latest"

    echo ":: fetching latest release metadata from $repo"

    # curl + jq must be present before we can read the release JSON.
    sudo -A pacman -S --needed --noconfirm curl jq
    or begin
        set_color red
        echo ':: failed to install curl + jq (needed to query the GitHub API)'
        set_color normal
        exit 1
    end

    set -l release_json (curl -fsSL $api 2> /dev/null)
    if test -z "$release_json"
        set_color red
        echo ":: failed to query $api"
        echo "   (no releases yet? re-run with --skip-packages and push a v* tag first)"
        set_color normal
        exit 1
    end

    set -l asset_urls (echo $release_json \
        | jq -r '.assets[] | select(.name | test("caelestia-(cli|shell).*\\.pkg\\.tar\\.zst$")) | .browser_download_url')
    if test (count $asset_urls) -lt 2
        set_color red
        echo ':: latest release does not contain both caelestia-cli and caelestia-shell .pkg.tar.zst'
        echo '   assets found:'
        for u in $asset_urls
            echo "     - $u"
        end
        set_color normal
        exit 1
    end

    set -l tmpdir (mktemp -d)
    for url in $asset_urls
        echo ":: downloading "(string split / -- $url)[-1]
        curl -fLS --output-dir $tmpdir -O $url
        or exit 1
    end

    echo ':: installing packages'
    sudo -A pacman -U --needed --noconfirm $tmpdir/*.pkg.tar.zst
    or exit 1

    rm -rf $tmpdir
end

# ─── 2. Run the dots installer ────────────────────────────────────────────────
set -l fwd
set -q _flag_noconfirm && set -a fwd --noconfirm
set -q _flag_aur_helper && set -a fwd --aur-helper=$_flag_aur_helper

./dots/install.fish $fwd
or exit 1

# ─── 3. Point Quickshell at our shell/ fork ───────────────────────────────────
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
