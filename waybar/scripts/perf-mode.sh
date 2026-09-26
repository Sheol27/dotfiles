#!/usr/bin/env bash

tlp=/run/current-system/sw/bin/tlp
signal=9  # keep in sync with "signal" in config.jsonc

current() {
    case "$(cat /run/tlp/manual_mode 2>/dev/null)" in
        0) echo performance ;;
        1) echo powersave ;;
        *) echo auto ;;
    esac
}

apply() {
    case "$1" in
        auto)        sudo -n "$tlp" start ;;
        performance) sudo -n "$tlp" ac ;;
        powersave)   sudo -n "$tlp" bat ;;
    esac >/dev/null 2>&1 || notify-send -u critical "Performance mode" \
        "Failed to switch to $1 (is the tlp sudo rule active?)"
    pkill -RTMIN+$signal waybar
}

status() {
    local mode profile icon text
    mode=$(current)
    profile=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo unknown)
    case "$mode" in
        performance) icon=$''; text="Performance" ;;
        powersave)   icon=$''; text="Power saver" ;;
        *)           icon=$''; text="Auto" ;;
    esac
    printf '{"text":"%s","alt":"%s","class":"%s","tooltip":"Power mode: %s (platform: %s)\\nClick: cycle  ·  Right-click: auto"}\n' \
        "$icon" "$mode" "$mode" "$text" "$profile"
}

case "${1:-status}" in
    status) status ;;
    next)
        case "$(current)" in
            auto)        apply performance ;;
            performance) apply powersave ;;
            *)           apply auto ;;
        esac ;;
    auto|performance|powersave) apply "$1" ;;
    *) echo "usage: $0 [status|next|auto|performance|powersave]" >&2; exit 1 ;;
esac
