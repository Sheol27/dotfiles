#!/bin/bash

# Set the XDG_CONFIG_HOME environment variable
export XDG_CONFIG_HOME="$HOME/.config"

# Create the necessary directories if they don't exist
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME/nixpkgs"

# Create symbolic links for nvim and config.nix, using absolute paths for clarity
ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"/nvim
ln -sf "$PWD/flake.nix" /tmp/flake.nix

echo "export TERM=screen-256color" >>"$HOME/.bashrc"

nvim --headless "+Lazy! sync" +qa
