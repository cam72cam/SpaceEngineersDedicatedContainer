# SpaceEngineersDedicatedContainer
Scripts to set up a dedicated SE server container on Linux

## Inspired by:
* https://github.com/mmmaxwwwell/space-engineers-dedicated-docker-linux
* https://github.com/Linux74656/SpaceEngineersLinuxPatches

## How to use:
Clone this repository to somewhere on your linux machine
Run `sudo ./scripts/bootstrap.sh`
The last line printed is the command to boot up the server

## How it works:
Systemd-nspawn is a front end to linux namespaced containers and is an easy way to boot up an isolated environment on any modern linux system.  Debootstrap is used to create a debian buster rootfs that can be nspawn'd into.  The install and setup scripts then install the latest wine, along with any other needed utilities and configuration.

Currently the default world file comes from mmmaxwwwell's repo, this will be configurable in the future.  For now you can remove the existing world and replace it manually in the server/home/wine/profile directory.

## TODO:
* Easier world customization
* Add flags to modify server config on install
