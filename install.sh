#!/bin/bash
set -euo pipefail

USERNAME="vscode"
USER_HOME="/home/$USERNAME"

echo "Installing Nix in single-user mode for $USERNAME..."

# Install Nix as vscode



# Copy config files
cp home.nix "$USER_HOME/home.nix"
# cp local_info.nix "$USER_HOME/local_info.nix"
cp install_user.sh "$USER_HOME/install_user.sh"
chown "$USERNAME":"$USERNAME" "$USER_HOME/install_user.sh"
chmod +x "$USER_HOME/install_user.sh"


mkdir -p "$USER_HOME/dotfiles"
cp -r dotfiles/. "$USER_HOME/dotfiles"

# Fix ownership
chown -R "$USERNAME":"$USERNAME" "$USER_HOME/home.nix" "$USER_HOME/dotfiles"

# Fix ownership of volumes
# chown -R "$USERNAME":"$USERNAME" /nix
# chown -R "$USERNAME":"$USERNAME" "$USER_HOME/.nix-profile"
# chown -R "$USERNAME":"$USERNAME" "$USER_HOME/.nix-defexpr"
# chown -R "$USERNAME":"$USERNAME" "$USER_HOME/.nix-channels"
# chown -R "$USERNAME":"$USERNAME" "$USER_HOME/.local/state/nix"
# chown -R "$USERNAME":"$USERNAME" "$USER_HOME/.cache/nix"

echo "Running local install script as $USERNAME..."
WELLKNOWN_FNAME=/tmp/wellknown-file
touch "$WELLKNOWN_FNAME"
chmod a+w "$WELLKNOWN_FNAME"
su - "$USERNAME" -c "~/install_user.sh $WELLKNOWN_FNAME"
echo "CHANGING SHELL TO $(cat $WELLKNOWN_FNAME)"
chsh -s $(cat $WELLKNOWN_FNAME) $USERNAME
# exit 1

