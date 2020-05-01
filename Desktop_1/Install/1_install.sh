#!/bin/bash

install_path="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P | sed 's/\/Install//')"
cursors_path="$install_path/Resources/Cursors"
sway_path="$install_path/Resources/Sway"

sudo pacman -S --noconfirm sway swaylock swayidle xorg-server-xwayland

mkdir $XDG_CONFIG_HOME/sway
cp "$sway_path""/*" $XDG_CONFIG_HOME/sway

echo '# Sway autostart
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=us exec sway
fi' >> ~/.bash_profile

echo "Setup cursors"
mkdir -p ~/.local/share/icons
for file in $(find $cursors_path -type f);
do
  tar xf $file -C ~/.local/share/icons/;
done
