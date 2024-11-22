#!/bin/bash
set -e -u -o pipefail

# Check for sudo if not root
SUDO=""
if [ "$EUID" -ne 0 ]; then
    if ! command -v sudo &> /dev/null; then
        echo "Neither root access nor sudo available, exitting"
        exit 1
    fi
    SUDO="sudo"
fi

NEEDED_COMMANDS="zsh sudo curl git tmux htop nano vim mc"

# Check for packages that need to be installed
missing_packages=()
for pkg in $NEEDED_COMMANDS; do
    if ! command -v "$pkg" &> /dev/null; then
        missing_packages+=("$pkg")
    fi
done

# Install missing packages if needed
if [ ${#missing_packages[@]} -ne 0 ]; then
    if command -v apt-get &> /dev/null; then
        $SUDO apt-get update
        $SUDO apt-get install -y "${missing_packages[@]}"
    elif command -v pacman &> /dev/null; then
        $SUDO pacman -Sy --noconfirm "${missing_packages[@]}"
    elif command -v dnf &> /dev/null; then
        $SUDO dnf install -y "${missing_packages[@]}"
    elif command -v yum &> /dev/null; then
        $SUDO yum install -y "${missing_packages[@]}"
    else
        echo "No supported package manager found (apt, pacman, dnf, or yum)"
        exit 1
    fi
fi

# Set shell to zsh for current user if available
if [ -e /bin/zsh ]; then
    echo "Changing shell to zsh for $(id -un)"
    $SUDO chsh -s /bin/zsh "$(id -un)"
fi

# Install the dotfiles
curl -fL https://raw.githubusercontent.com/gavento/dotfiles/refs/heads/main/.local/bin/dotfiles | bash -s - bootstrap-system

