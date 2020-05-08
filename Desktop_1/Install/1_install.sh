#!/bin/bash

install_path="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P | sed 's/\/Install//')"
cursors_path="$install_path/Resources/Cursors"
sway_path="$install_path/Resources/Sway"
wallp_path="$install_path/Resources/Wallpapers"
usrcust_path="$install_path/Resources/UserScripts"
rofi_path="$install_path/Resources/Rofi"
termite_path="$install_path/Resources/Termite"

sudo pacman -S --noconfirm sway swaylock swayidle xorg-server-xwayland termite rofi imagemagick grim slurp wl-clipboard

mkdir $XDG_CONFIG_HOME/sway
yes | cp -arf "$sway_path""/." $XDG_CONFIG_HOME/sway

echo '# Sway autostart
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=us exec sway
fi' >> ~/.bash_profile

echo "Setup cursors"
mkdir -p ~/.local/share/icons
for file in $(find $cursors_path -type f);
do
  tar -xf $file -C ~/.local/share/icons/;
done

echo "Setup wallpapers"
mkdir -p ~/Pictures/Wallpapers
for file in $(find $wallp_path -type f);
do
  tar -xf $file -C ~/Pictures/Wallpapers/;
done

echo "Setup GTK dark"
echo "gtk-application-prefer-dark-theme = true" >> "$XDG_CONFIG_HOME/gtk-3.0/settings.ini"

echo "Setup user scripts"
yes | sudo cp -arf "$usrcust_path""/." /usr/local/bin

echo "Setup Rofi"
mkdir $XDG_CONFIG_HOME/rofi
yes | cp -arf "$rofi_path""/." $XDG_CONFIG_HOME/rofi

echo "Setup Termite"
mkdir $XDG_CONFIG_HOME/termite
yes | cp -arf "$termite_path""/." $XDG_CONFIG_HOME/termite

echo "Setup Neovim"
mkdir $XDG_DATA_HOME/nvim/plugged
sh -c 'curl -flo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo "call plug#begin('\$XDG_DATA_HOME/nvim/plugged')" >> $XDG_CONFIG_HOME/nvim/init.vim
echo "call plug#end()" >> $XDG_CONFIG_HOME/nvim/init.vim
