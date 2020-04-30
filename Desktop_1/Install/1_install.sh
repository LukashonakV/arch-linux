#!/bin/bash

install_path="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P | sed 's/\/Install//')"
cursors_path="$install_path/Resources/Cursors"

sudo pacman -S --noconfirm sway swaylock swayidle xorg-server-xwayland

mkdir $XDG_CONFIG_HOME/sway
cp /etc/sway/config $XDG_CONFIG_HOME/sway

echo '# Sway autostart
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=us exec sway
fi' >> ~/.bash_profile

echo "Setup cursors"
for file in $(find $cursors_path -type f);
do
  tar xf $file -C ~/.icons;
done

echo "Inherits=capitaine-cursors" >> ~/.icons/default/index.theme
echo "gtk-cursor-theme-name=capitaine-cursors" >> $XDG_CONFIG_HOME/gtk-3.0/settings.ini
