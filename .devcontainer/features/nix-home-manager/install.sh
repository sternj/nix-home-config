#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-vscode}"
USER_HOME="/home/$USERNAME"
HOME_NIX_PATH="${_BUILD_ARG_HOMENIXPATH:-/workspaces/$(basename "${PWD}")/home.nix}"
NIX_PROFILE="/home/$USERNAME/.nix-profile"
echo "Installing Determinate Nix for $USERNAME..."
# curl -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --init none
sudo -u "$USERNAME" bash -c "
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --init none \
  --no-confirm
"
# Make Nix available in this shell


echo "Installing Home Manager and zsh..."

echo "Ensuring nix environment loads for $USERNAME"
sudo -u "$USERNAME" bash -c "
  mkdir -p \"$USER_HOME/.config/nix\"
  echo '. \"$NIX_PROFILE/etc/profile.d/nix-daemon.sh\"' >> \"$USER_HOME/.bashrc\"
  echo 'export NIX_REMOTE=daemon' >> \"$USER_HOME/.bashrc\"
  echo 'export PATH=$NIX_PROFILE/bin:\$PATH' >> \"$USER_HOME/.bashrc\"
"

echo "Installing Home Manager for $USERNAME..."
sudo -u "$USERNAME" bash -c "
  source \"$NIX_PROFILE/etc/profile.d/nix-daemon.sh\"
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix profile install github:nix-community/home-manager
"

echo "Applying Home Manager config at $HOME_NIX_PATH"
sudo -u "$USERNAME" bash -c "
  source \"$NIX_PROFILE/etc/profile.d/nix-daemon.sh\"
  export HOME=\"$USER_HOME\"
  export USER=\"$USERNAME\"
  home-manager switch -f \"$HOME_NIX_PATH\"
"

