FROM ubuntu:22.04

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y curl sudo git xz-utils && \
    useradd -ms /bin/bash vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode
WORKDIR /home/vscode

# Install Nix
RUN curl -L https://nixos.org/nix/install | sh

# Enable Nix for non-login shells
ENV USER=vscode
ENV NIX_PATH=/home/vscode/.nix-defexpr/channels
ENV PATH=/home/vscode/.nix-profile/bin:/home/vscode/.nix-profile/sbin:$PATH
ENV ENV=/home/vscode/.nix-profile/etc/profile.d/nix.sh

# Set up home-manager channel and install it
RUN . /home/vscode/.nix-profile/etc/profile.d/nix.sh && \
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && \
    nix-channel --update && \
    nix-shell '<home-manager>' -A install

ENTRYPOINT [ "bash" ]
