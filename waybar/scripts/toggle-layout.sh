#!/usr/bin/env bash

dir="$(dirname "$(realpath "$0")")/.."
cd "$dir" || exit 1

if [ "$(readlink layout.jsonc)" = layouts/horizontal.jsonc ]; then
    ln -sfn layouts/vertical.jsonc layout.jsonc
else
    ln -sfn layouts/horizontal.jsonc layout.jsonc
fi

pkill -USR2 waybar
