#!/bin/bash

function info() {
   echo -e "$(tput bold;tput setaf 2)$@$(tput sgr 0)"
}

WINETRICKS=~/scripts/winetricks
info "Downloading Winetricks to $WINETRICKS..."
curl -L https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -o $WINETRICKS
chmod +x $WINETRICKS

SPACEENGINEERS=~/SpaceEngineers
export WINEARCH=win64
export WINEDEBUG=-all
export WINEPREFIX=~/.wine/spaceengineers


info "Setting up wine prefix..."
mkdir -p $WINEPREFIX
WINEDLLOVERRIDES="mscoree=d" wineboot --init /nogui
$WINETRICKS sound=disabled
$WINETRICKS corefonts
Xvfb :5 -screen 0 1024x768x16 &
export DISPLAY=:5.0
#$WINETRICKS -q vcrun2017
$WINETRICKS -q --force vcrun2015
$WINETRICKS -q --force dotnet48
#$WINETRICKS -q vcrun2013
unset DISPLAY
kill %1

info "Downloading example world (Star System)..."
mkdir ~/profile
cd ~/profile
curl https://raw.githubusercontent.com/mmmaxwwwell/space-engineers-dedicated-docker-linux/master/star-system.zip -O
unzip star-system.zip
rm star-system.zip
sed -i SpaceEngineers-Dedicated.cfg -e 's,<LoadWorld>.*</LoadWorld>,<LoadWorld>Z:\\home\\wine\\profile\\World</LoadWorld>,'
sed -i SpaceEngineers-Dedicated.cfg -e 's,<PremadeCheckpointPath>.*</PremadeCheckpointPath>,<PremadeCheckpointPath>Z:\\home\\wine\\profile\\Checkpoint</PremadeCheckpointPath>,'
cd $HOME

cat>"scripts/start.sh"<<EOT
#!/bin/bash

echo "Downloading/Updating Space Engineers Dedicated..."
steamcmd +login anonymous +@sSteamCmdForcePlatformType windows +force_install_dir $SPACEENGINEERS +app_update 298740 +quit

echo "Starting Space Engineers Server..."
cd $SPACEENGINEERS
export WINEARCH=$WINEARCH
export WINEDEBUG=$WINEDEBUG
export WINEPREFIX=$WINEPREFIX
wine DedicatedServer64/SpaceEngineersDedicated.exe -console -path Z:\\\\home\\\\wine\\\\profile -ignorelastsession
EOT
chmod +x scripts/start.sh
