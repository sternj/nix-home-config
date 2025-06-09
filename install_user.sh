#!/bin/bash
set -euo pipefail
export TMPDIR_DEST=$1
export USER=$(whoami)
echo "Running curl -L https://nixos.org/nix/install "

# curl -L https://releases.nixos.org/nix/nix-$NIX_VERSION/install | bash -s -- --no-daemon
sh <(curl -L https://nixos.org/nix/install) --no-daemon
# Source nix profile (installed by nix installer)
. ~/.nix-profile/etc/profile.d/nix.sh
echo "LISTING"
nix-channel --list
nix-channel --add https://nixos.org/channels/nixos-25.05
# Add and update home-manager channel (compatible version)
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --update

# Install home-manager
nix-shell '<home-manager>' -A install

# Generate local_info.nix by running the script
cd "$HOME"
echo "CWD"
pwd
echo "LISTING"
ls -la
# chmod +x ./gen_local_info.sh
# ./gen_local_info.sh

# Activate home-manager config
isContainer=true home-manager switch -f ~/home.nix  --impure
echo "CHSH"
echo $(which zsh)
echo $(which zsh) > $TMPDIR_DEST
# echo chsh -s $(which zsh)
# chsh -s $(which zsh)