#!/bin/bash

install_path="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P | sed 's/\/Install//')"
cursors_path="$install_path/Resources/Cursors"

sudo pacman -S sway swaylock swayidle xorg-server-xwayland

mkdir $XDG_CONFIG_HOME/sway
cp /etc/sway/config $XDG_CONFIG_HOME/sway

echo '# Sway autostart
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=us exec sway
fi' >> ~/.bash_profile

for file in $(find cursors_path -type f);
do
  tar xf $file -C ~/.icons;
done
