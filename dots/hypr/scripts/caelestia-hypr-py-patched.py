import json
import os
import re
import socket
from typing import Any

socket_base = f"{os.getenv('XDG_RUNTIME_DIR')}/hypr/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}"
socket_path = f"{socket_base}/.socket.sock"
socket2_path = f"{socket_base}/.socket2.sock"


# ---------------------------------------------------------------------------
# Lua-config compat
# Hyprland 0.55+ replaces the legacy hyprlang config with Lua. Under that
# config, the `dispatch` IPC endpoint wraps incoming text as
#     return hl.dispatch(<text>)
# and evaluates as Lua — so legacy `togglespecialworkspace music` etc. all
# parse as syntax errors. This module translates the legacy dispatcher
# names used by caelestia-cli (toggle, resizer) into the equivalent
# `hl.dsp.*` Lua expressions. Falls back to the literal string for
# anything we don't recognise.
# ---------------------------------------------------------------------------


def _quote(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _legacy_to_lua(d: str, arg_str: str) -> str:
    """Translate a `<dispatcher> <space-separated args>` legacy form into a
    Lua dispatcher object expression (no `hl.dispatch(...)` wrap — the
    server adds that). Returns the original text unchanged if no rule
    matches; the server will then emit its usual error."""

    arg_str = arg_str.strip()

    if d == "togglespecialworkspace":
        name = arg_str or "special"
        return f'hl.dsp.workspace.toggle_special({_quote(name)})'

    if d in ("movetoworkspace", "movetoworkspacesilent"):
        # arg: "<workspace>[,address:<addr>]"
        ws, _, rest = arg_str.partition(",")
        opts = [f'workspace={_quote(ws)}']
        m = re.match(r"address:(0x[0-9a-fA-F]+)", rest)
        if m:
            opts.append(f'address={_quote(m.group(1))}')
        if d == "movetoworkspacesilent":
            opts.append("follow=false")
        return f'hl.dsp.window.move({{{",".join(opts)}}})'

    if d == "exec":
        # arg may be raw command, possibly with `[rules]` prefix.
        return f'hl.dsp.exec_cmd({_quote(arg_str)})'

    if d == "resizewindowpixel":
        # "exact W H,address:ADDR" or "W H,address:ADDR" or just "W H"
        m = re.match(r"(?:(exact)\s+)?(\S+)\s+(\S+)(?:,address:(0x[0-9a-fA-F]+))?", arg_str)
        if m:
            exact, w, h, addr = m.groups()
            opts = [f"x={w}", f"y={h}"]
            if exact:
                opts.append("exact=true")
            if addr:
                opts.append(f"address={_quote(addr)}")
            return f'hl.dsp.window.resize({{{",".join(opts)}}})'

    if d == "movewindowpixel":
        # "exact X Y,address:ADDR"
        m = re.match(r"(?:(exact)\s+)?(\S+)\s+(\S+)(?:,address:(0x[0-9a-fA-F]+))?", arg_str)
        if m:
            exact, x, y, addr = m.groups()
            opts = [f"x={x}", f"y={y}"]
            if exact:
                opts.append("exact=true")
            if addr:
                opts.append(f"address={_quote(addr)}")
            return f'hl.dsp.window.move({{{",".join(opts)}}})'

    if d == "togglefloating":
        opts = ['action="toggle"']
        m = re.match(r"address:(0x[0-9a-fA-F]+)", arg_str)
        if m:
            opts.append(f'address={_quote(m.group(1))}')
        return f'hl.dsp.window.float({{{",".join(opts)}}})'

    if d == "centerwindow":
        return "hl.dsp.window.center()"

    if d == "pin":
        opts = []
        m = re.match(r"address:(0x[0-9a-fA-F]+)", arg_str)
        if m:
            opts.append(f'address={_quote(m.group(1))}')
        return f'hl.dsp.window.pin({{{",".join(opts)}}})' if opts else "hl.dsp.window.pin()"

    if d == "killwindow":
        opts = []
        m = re.match(r"address:(0x[0-9a-fA-F]+)", arg_str)
        if m:
            opts.append(f'address={_quote(m.group(1))}')
        return f'hl.dsp.window.close({{{",".join(opts)}}})' if opts else "hl.dsp.window.close()"

    if d == "workspace":
        return f'hl.dsp.focus({{workspace={_quote(arg_str)}}})'

    # Fallback: pass through as-is. The server will reject if needed.
    return f"{d} {arg_str}".rstrip()


def _translate_dispatch_msg(msg: str) -> str:
    """For a full `dispatch <dispatcher> <args>` line, translate the body."""
    if not msg.startswith("dispatch "):
        return msg
    body = msg[len("dispatch "):]
    parts = body.split(None, 1)
    d = parts[0] if parts else ""
    arg_str = parts[1] if len(parts) > 1 else ""
    return "dispatch " + _legacy_to_lua(d, arg_str)


def message(msg: str, is_json: bool = True) -> str | dict[str, Any]:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(socket_path)

        if is_json:
            msg = f"j/{msg}"
        sock.send(msg.encode())

        resp = sock.recv(8192).decode()
        while True:
            new_resp = sock.recv(8192)
            if not new_resp:
                break
            resp += new_resp.decode()

        return json.loads(resp) if is_json else resp


def dispatch(dispatcher: str, *args: str) -> bool:
    arg_str = " ".join(map(str, args)).strip()
    lua = _legacy_to_lua(dispatcher, arg_str)
    return message(f"dispatch {lua}", is_json=False) == "ok"


def batch(*msgs: str, is_json: bool = False) -> str | dict[str, Any]:
    translated = [_translate_dispatch_msg(m) for m in msgs]

    if is_json:
        translated = [f"j/{m.strip()}" for m in translated]

    return message(f"[[BATCH]]{';'.join(translated)}", is_json=False)
