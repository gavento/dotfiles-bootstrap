#!/bin/bash
set -e -u -o pipefail

inst() {
    # If not root, then exit
    if [ "$EUID" -ne 0 ] ; then
        echo "Can't install missing package $1: needs to be run as root"
        exit
    fi
    if command -v apt-get &> /dev/null ; then
        apt-get update
        apt-get install -y $1
    else
        echo "Can't install missing package $1: no known package manager found (apt)"
        exit
    fi
}

# Check for curl, zsh, and git being installed

if ! command -v curl &> /dev/null ; then inst curl; fi
if ! command -v zsh &> /dev/null ; then inst zsh; fi
if ! command -v git &> /dev/null ; then inst git; fi

# Set shell to be zsh if /bin/zsh exists
if [ -e /bin/zsh ] ; then
    chsh -s /bin/zsh
fi

# Install the gavento/dotfiles repo via curl
curl -fL https://raw.githubusercontent.com/gavento/dotfiles/refs/heads/main/.local/bin/dotfiles | bash -s - bootstrap-apt

