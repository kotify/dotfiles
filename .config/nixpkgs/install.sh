#!/usr/bin/env bash
set -e

SOURCE=$PWD/overlays
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/nixpkgs"
mkdir -p "$HOME/.config/nixpkgs/overlays"
if [[ ! -f "$HOME/.config/nixpkgs/config.nix" ]]
then
    cp ./config.nix "$HOME/.config/nixpkgs/config.nix"
fi
cd "$HOME/.config/nixpkgs/overlays"
ln -fs "$SOURCE"/kotify-packages.nix .
exec nix-env -f '<nixpkgs>' -r -iA userPackages
