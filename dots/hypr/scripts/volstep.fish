#!/usr/bin/env fish
# Perceptual (cubic) volume step. wpctl writes volume as linear amplitude
# (0.5 = -6 dB); human hearing is logarithmic, so the lower half of the
# slider sounds dead and the upper half jumps. Step in cube-root space.
#
# Usage: volstep.fish up|down [percent]   # default percent = 10
#
# Precision: wpctl get-volume rounds to 2 decimals, which loses any value
# below ~0.005 linear (the script would get stuck at "0.00"). We persist
# the *perceptual* position in $XDG_RUNTIME_DIR/caelestia/volstep.state and
# trust it as long as it round-trips close to the displayed linear value;
# any larger discrepancy (something else changed volume) snaps us to the
# linear-derived value.

set -l dir   $argv[1]
set -l pct   (test -n "$argv[2]"; and echo $argv[2]; or echo 10)
set -l step  (math "$pct / 100")

set -l line  (wpctl get-volume @DEFAULT_AUDIO_SINK@)
set -l cur   (echo $line | string match -rg 'Volume: ([0-9.]+)')
test -z "$cur"; and exit 1

# Perceptual position derived from the current (display-rounded) linear value.
set -l p_from_linear (awk "BEGIN { printf \"%.6f\", ($cur)^(1/3) }")

# Recover the high-precision perceptual position from our state file if the
# value it implies still rounds to the same displayed linear (otherwise
# something external changed the volume — fall back to the rounded value).
set -l state_dir "$XDG_RUNTIME_DIR/caelestia"
set -l state "$state_dir/volstep.state"
mkdir -p $state_dir

set -l p $p_from_linear
if test -f $state
    set -l p_saved (cat $state)
    if test -n "$p_saved"
        set -l implied (awk "BEGIN { printf \"%.2f\", ($p_saved)^3 }")
        if test "$implied" = "$cur"
            set p $p_saved
        end
    end
end

switch $dir
    case up
        set p (awk "BEGIN { v = $p + $step; if (v > 1) v = 1; printf \"%.6f\", v }")
    case down
        set p (awk "BEGIN { v = $p - $step; if (v < 0) v = 0; printf \"%.6f\", v }")
    case '*'
        echo "usage: volstep.fish up|down [percent]" >&2
        exit 2
end

# Persist perceptual position, write linear amplitude.
echo -n $p > $state
set -l new (awk "BEGIN { printf \"%.6f\", ($p)^3 }")
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ $new
