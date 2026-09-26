#!/usr/bin/env bash
# Toggle a floating nmtui window (placed by the "wifi-tui" rules in hyprland.conf).

CLASS=wifi-tui
[ "$(readlink "$(dirname "$(realpath "$0")")/../layout.jsonc")" = layouts/horizontal.jsonc ] &&
    CLASS=wifi-tui-top

if hyprctl clients | grep -q "class: wifi-tui"; then
    hyprctl dispatch closewindow "class:^(wifi-tui.*)$" >/dev/null
    exit 0
fi

export NEWT_COLORS='
root=white,black
window=white,black
border=gray,black
shadow=black,black
title=magenta,black
roottext=white,black
textbox=white,black
label=white,black
listbox=white,black
actlistbox=white,black
sellistbox=black,cyan
actsellistbox=black,magenta
button=black,gray
actbutton=black,magenta
compactbutton=white,black
checkbox=white,black
actcheckbox=black,magenta
entry=white,gray
disentry=gray,black
helpline=black,black
emptyscale=,black
fullscale=,magenta
'

exec kitty --class "$CLASS" --title "Wi-Fi" \
    -o background=#1e1f29 -o foreground=#f8f8f2 \
    -o color0=#1e1f29 -o color7=#f8f8f2 -o color15=#f8f8f2 -o color8=#44475a \
    -o color5=#bd93f9 -o color6=#8be9fd \
    -o window_padding_width=12 -o font_size=11 \
    -o confirm_os_window_close=0 -o cursor_shape=block \
    nmtui connect
