#!/bin/bash

function info() {
    echo -e "$(tput bold;tput setaf 2)$@$(tput sgr 0)"
}
function error() {
    echo -e "$(tput bold;tput setaf 1)$@$(tput sgr 0)"
    exit -1
}

if [ "$EUID" -ne 0 ]; then
    error "Please run 'sudo $0' as root permissions are required"
fi

if [ ! -f `which debootstrap` ]; then
    error "Debootstrap not installed, please run sudo apt install debootstrap (or equivalent)"
fi

info "Installing debian buster to $PWD/server/ ..."
debootstrap buster $PWD/server/

info "Installing dependencies in $PWD/server/ ..."
cp scripts/install.sh $PWD/server/
systemd-nspawn -D $PWD/server/ bash -l /install.sh

info "Setting up Space Engineers server in $PWD/server/ ..."
systemd-nspawn -u wine -D $PWD/server/ mkdir -p /home/wine/scripts/
cp scripts/setup.sh $PWD/server/home/wine/scripts/
systemd-nspawn -u wine -D $PWD/server/ bash -l /home/wine/scripts/setup.sh

info "Installation complete, run the following to start Space Engineers Dedicated Server:"
echo "'sudo systemd-nspawn -u wine -D server/ bash -l /home/wine/scripts/start.sh'"

