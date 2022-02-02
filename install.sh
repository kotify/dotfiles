#!/usr/bin/env bash
set -exo pipefail

NIXPKGS_SOURCE=$PWD/.config/nixpkgs
NIXPKGS_TARGET="$HOME/.config/nixpkgs"
mkdir -p "$NIXPKGS_TARGET/overlays"
[[ ! -f "$HOME/.config/nixpkgs/config.nix" ]] && cp -n "$NIXPKGS_SOURCE/config.nix" "$NIXPKGS_TARGET/config.nix"
(cd "$NIXPKGS_TARGET/overlays" && ln -fs "$NIXPKGS_SOURCE/overlays/kotify-packages.nix" .)
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
nix-env -f '<nixpkgs>' -r -iA userPackages

DIRENV_SOURCE="$PWD/.config/direnv"
DIRENV_TARGET="$HOME/.config/direnv"
mkdir -p "$DIRENV_TARGET"
(cd "$DIRENV_TARGET" && ln -fs "$DIRENV_SOURCE/direnvrc" .)
