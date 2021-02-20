#!/bin/bash

function info() {
   echo -e "$(tput bold;tput setaf 2)$@$(tput sgr 0)"
}

info "Allowing i386 packages to be installed..."
dpkg --add-architecture i386 
apt update
apt upgrade -y 

info "Setting up winehq software repository..."
apt install curl gnupg2 software-properties-common -y 
curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add - 
apt-add-repository https://dl.winehq.org/wine-builds/debian/ 
apt-add-repository non-free 
apt update

info "Installing custom libfaudio packages (wine dependency)..."
curl -L https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/i386/libfaudio0_20.01-0~buster_i386.deb > libfaudio0_20.01-0~buster_i386.deb 
curl -L https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/amd64/libfaudio0_20.01-0~buster_amd64.deb > libfaudio0_20.01-0~buster_amd64.deb 
dpkg -i --force-depends libfaudio0_20.01-0~buster_i386.deb 
dpkg -i --force-depends libfaudio0_20.01-0~buster_amd64.deb 
apt install -f -y 
rm *.deb 

info "Installing wine stable"
apt install --install-recommends winehq-stable -y 

info "Installing steam and other dependencies..."
echo steam steam/question select "I AGREE" | debconf-set-selections 
apt install steamcmd xvfb cabextract unzip vim -y 

info "Creating wine user..."
adduser wine --disabled-password --gecos "" 

info "Cleaning up..."
apt purge software-properties-common gnupg2 -y
apt autoclean 
apt autoremove -y 
