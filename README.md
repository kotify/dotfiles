## Nix

### Setup Nix

Install on MacOS: `sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume`.

Install on Linux: `curl -L https://nixos.org/nix/install | sh`.

Currently we use unstable channel of nixpkgs, enable it: `nix-channel --add https://nixos.org/channels/nixpkgs-unstable`.

Install configs: `cd ./.config/nixpkgs && ./install.sh`.

Install all packages: `nix-rebuild`.

### Working with Nix

To install other packages create your own overlay file in `~/.config/nixpkgs/overlays`, see [my-packages.nix](https://github.com/kalekseev/dotfiles/blob/master/nixpkgs/overlays/my-packages.nix) for example.

Everytime you update overlay's files you need to run `nix-rebuild` command.

To update packages to latest versions run `nix-channel --update && nix-rebuild`.
