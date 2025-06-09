#!/bin/bash
set -euo pipefail
export TMPDIR_DEST=$1
export USER=$(whoami)

NIX_PROFILE_SH="$HOME/.nix-profile/etc/profile.d/nix.sh"
NIX_BIN_DIR="$HOME/.nix-profile/bin"
NIX_SBIN_DIR="$HOME/.nix-profile/sbin"

mkdir -p "$HOME/.nix-data"

if [ -f "$HOME/.nix-data/nix-channels" ]; then
  echo "Restoring .nix-channels from persistent storage..."
  cp "$HOME/.nix-data/nix-channels" "$HOME/.nix-channels"
fi

echo "Running curl -L https://nixos.org/nix/install "

# curl -L https://releases.nixos.org/nix/nix-$NIX_VERSION/install | bash -s -- --no-daemon
sh <(curl -L https://nixos.org/nix/install) --no-daemon
# Source nix profile (installed by nix installer)
. ~/.nix-profile/etc/profile.d/nix.sh
echo "LISTING"
if [ -f "$NIX_PROFILE_SH" ]; then
  echo "Sourcing existing Nix profile..."
  . "$NIX_PROFILE_SH"
fi

if ! command -v nix &> /dev/null; then
  echo "Nix not found. Installing..."
  sh <(curl -L https://nixos.org/nix/install) --no-daemon

  # Source and re-patch PATH after install
  . "$NIX_PROFILE_SH"
else
  echo "Nix already installed."
fi
# nix-channel --list
# nix-channel --add https://nixos.org/channels/nixos-25.05
# # Add and update home-manager channel (compatible version)
# nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
# nix-channel --update
echo "Checking nix channels..."
expected_nix_channel="https://nixos.org/channels/nixos-25.05"
expected_home_manager_channel="https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz"

needs_channel_update=false
echo "Listing channels"
nix-channel --list 
if ! nix-channel --list | grep -qF "$expected_nix_channel"; then
  nix-channel --add "$expected_nix_channel"
  needs_channel_update=true
fi

# nix-channel --list | grep -qF "$expected_home_manager_channel"
if ! nix-channel --list | grep -qF "home-manager" || \
   ! nix-channel --list | grep -qF "$expected_home_manager_channel"; then
  nix-channel --add "$expected_home_manager_channel" home-manager
  needs_channel_update=true
fi

if [ "$needs_channel_update" = true ]; then
  echo "Updating nix channels..."
  nix-channel --update
  . "$NIX_PROFILE_SH"
else
  echo "Channels already set correctly."
fi

# Install home-manager
# nix-shell '<home-manager>' -A install
if ! command -v home-manager &> /dev/null; then
  echo "Installing Home Manager..."
  nix-shell '<home-manager>' -A install

  # Add its bin dir to PATH if needed
  export PATH="$HOME/.nix-profile/bin:$PATH"
else
  echo "Home Manager already installed."
fi
# Generate local_info.nix by running the script
cd "$HOME"

echo "Saving .nix-channels to persistent storage..."
cp "$HOME/.nix-channels" "$HOME/.nix-data/nix-channels"
IS_CONTAINER=true home-manager switch -f ~/home.nix  --impure

echo $(which zsh) > $TMPDIR_DEST
# echo chsh -s $(which zsh)
# chsh -s $(which zsh)