function cld --wraps='claude --dangerously-skip-permissions' --description 'alias cld=claude --dangerously-skip-permissions'
    set -x SUDO_ASKPASS /usr/bin/lxqt-openssh-askpass
    claude --dangerously-skip-permissions $argv
end
